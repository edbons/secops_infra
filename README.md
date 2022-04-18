# Сравнение статических анализаторов уязвимостей в коде (SAST) для Kotlin

Для сравнение выбраны следующие решения:

1. SAST [Insider](https://github.com/insidersec/insider).
2. SAST [Checkmarx](https://checkmarx.com/product/cxsast-source-code-scanning/). Ввиду отсутствия общедоступной версии решения, выполнен только анализ документации.
3. SAST [Horusec](https://github.com/ZupIT/horusec).
4. [Sonarqube CE](https://www.sonarqube.org/).

В качестве анализируемого кода используется проект [Goatlin](https://github.com/Checkmarx/Goatlin). Он включает уязвимый код клиентской части на Kotlin, и серверной части на JS. Проект сделан с учетом типов уязвимостей, описанных в другом проекте команды Checkmarx - [Kotlin Guide - Mobile Application Secure Coding Practices](https://github.com/Checkmarx/Kotlin-SCP).

## Сравнение

* сравнение числа правил Checkmarx и Insider приведено в notebooks/01.sast_compare.ipynb
* отчеты сканирования на уязвимости Insider и Horusec приведены в каталоге reports, для Sonarqube отчеты в приложении только доступны.

|                                     | Checkmarx        | Insider | Horusec                                                                                             | Sonarqube       |
|-------------------------------------|------------------|---------|-----------------------------------------------------------------------------------------------------|-----------------|
| Общее число правил для Kotlin       | 58               | 34      | 40                                                                                                  | 25              |
| Число выявленных уязвимостей Kotlin | Нет данных        | 24      | 5                                                                                                   | 0               |
| Написание собственных правил        | DSL (query lang) | Regex   | Go                                                                                                  | DSL             |
| Интеграция c CI                     | CLI, [CI plugins](https://checkmarx.com/why-checkmarx/integrations/integrations-with-ci-cd-tools/) | CLI, docker container  | CLI, [docker container](https://docs.horusec.io/docs/cli/installation/#2-installation-via-pipeline) | CLI, [CI plugins](https://docs.sonarqube.org/latest/analysis/overview/) |


## Порядок запуска SAST

1. Задать переменные окружения для JENKINS:
   * JENKINS_ADMIN_ID - логин нового пользователя JENKINS;
   * JENKINS_ADMIN_PASSWORD - пароль для нового пользователя JENKINS.
2. Запустить инфраструктуру проекта Jenkins, Sonarqube:

```
docker compose -f infra-compose.yaml -p sast-infra up -d --build
```

2. В Sonarqube создать проект и получить токен для доступа к проекту.
3. Задать переменные окружения для Sonarqube:
   * SONAR_PROJECT - название проекта в Sonarqube;
   * SONAR_TOKEN  - токен для доступа к проекту в Sonarqube.
4. Запустить сканирование:

```
docker compose -f sast-compose.yaml -p sast-cli up -d
```


## Результаты

1. Checkmarx содержит большее число проверок на уязвимости для языка Kotlin по сравнению с Insider 58 против 34.
2. 8 типов уязвимостей (CWE) учтено в правилах и в том и другом решении.
3. При объединении проверок Checkmarx и Insider можно получить покрытие 51 CWE.
4. Детальный анализ содержимого правил не проводился, т.к. нет в открытом доступе кода правил для Checkmarx.

## Задачи для реализации

1. ~~Выполнять статическое тестирование безопасности приложения (SAST).~~
2. ~~Выполнять проверку зависимостей (dependancy check) в конвейере.~~
3. ~~Добавить агент Jenkins с управлением Docker.~~
4. ~~Выполнять сборку образа приложения.~~
5. ~~Выполнять проверку безопасности образа приложения.~~
6. ~~Выполнять динамическое тестирование безопасности приложения (DAST).~~
7. ~~Выгружать отчеты проверок из конвейера в централизованную систему.~~
8. Разработать parser DefectDojo для отчета SAST insider.
9. Запускать контейнеры для тестирования в k8s.


## Порядок запуска SecOps инфраструктуры

1. Задать переменные окружения для JENKINS:
   * JENKINS_ADMIN_ID - логин нового пользователя JENKINS;
   * JENKINS_ADMIN_PASSWORD - пароль для нового пользователя JENKINS.
2. Запустить инфраструктуру проекта Jenkins, Sonarqube:

```
docker compose -f infra-compose.yaml -p sast-infra up -d --build
```

3. Склонировать проект DefectDojo (выполняется в командной строке Windows):

```
git clone https://github.com/DefectDojo/django-DefectDojo.git --config core.autocrlf=input
```

4. Скопировать в каталог DefectDojo  дополнения (файл docker compose) и запустить DefectDojo (выполняется в командной строке Windows):

```
copy defectdojo-compose.overide.jenkinsnet.yml django-DefectDojo/defectdojo-compose.overide.jenkinsnet.yml
cd django-DefectDojo
set PROFILE=postgres-rabbitmq
docker-compose -f docker-compose.yml -f docker-compose.overide.jenkinsnet.yml --profile %PROFILE% --env-file ./docker/environments/%PROFILE%.env up -d --no-deps
```

5. В логе DefectDojo найти сгенерированный пароль для admin:

```
docker-compose logs initializer | grep "Admin password:"
```

6. В интерфейсе DefectDojo http://127.0.0.1:8080 для пользователя admin получить API токен ([docs](https://defectdojo.github.io/django-DefectDojo/integrations/api-v2-docs/)).
7. Токен сохранить в Secret Text credentials Jenkins с ID "defect.dojo".
8. В интерфейсе JENKINS http://127.0.0.1:8081 запустить задание "goatlin-scan".
9. В интерфейсе DefectDojo http://127.0.0.1:8080 можно просмотреть отчеты о сканировании для продукта Goatlin.

## Проблемы

1. Подключение агента Jenkins к серверу docker (dind) выполняется по незащищенному протоколу (порт 2375).
2. В конвейере выполняется каждый раз обновление списка пакетов на агенте (apt-get update) и установка пакета wget. Для установки wget агент запускается с правами root.
3. Каждый раз на агенте выгружается база dependancy check.
4. [DependencyCheck] [WARN] Analyzing `/var/jenkins_home/workspace/goatlin-scan/packages/services/api/package-lock.json` - however, the node_modules directory does not exist. Please run `npm install` prior to running dependency-check
5. Получение токена DefectDojo выполняется вручную.
6. Warning: A secret was passed to "sh" using Groovy String interpolation, which is insecure.
