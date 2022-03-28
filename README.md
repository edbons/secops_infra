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


## Порядок запуска

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

5. (Опционально) В интерфейсе JENKINS http://127.0.0.1:8081 запустить задание "goatlin-scan", настроенного для демонстрации встраивания sast в pipeline.

## Результаты

1. Checkmarx содержит большее число проверок на уязвимости для языка Kotlin по сравнению с Insider 58 против 34.
2. 8 типов уязвимостей (CWE) учтено в правилах и в том и другом решении.
3. При объединении проверок Checkmarx и Insider можно получить покрытие 51 CWE.
4. Детальный анализ содержимого правил не проводился, т.к. нет в открытом доступе кода правил для Checkmarx.

## Задачи для реализации

1. ~~Выполнять статическое тестирование безопасности приложения (SAST).~~
2. ~~Выполнять проверку зависимостей (dependancy check) в конвейере.~~
3. Добавить агент Jenkins с управлением Docker.
4. Выполнять сборку образа приложения.
5. Выполнять проверку безопасности образа приложения.
6. Выполнять динамическое тестирование безопасности приложения (DAST).
7. Выгружать отчеты проверок из конвейера в централизованную систему.
