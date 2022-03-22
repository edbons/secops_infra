# Starting off with the Jenkins base Image
FROM jenkins/jenkins:lts-jdk11

USER root
RUN apt-get update && apt-get install -y wget

USER jenkins

ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

# Plugins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# URL and Admin User
COPY --chown=jenkins:jenkins casc.yaml /var/jenkins_home/casc.yaml

# Skip the initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

VOLUME /var/jenkins_home