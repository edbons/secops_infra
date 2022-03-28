# Starting off with the Jenkins base Image
FROM jenkins/jenkins:lts-jdk11

USER root
RUN apt-get update && apt-get install -y wget lsb-release

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

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