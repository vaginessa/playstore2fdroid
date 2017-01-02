FROM ubuntu:16.04
MAINTAINER HeaDBanGer84

ENV RACCOON_VERSION 3.7

# Enable i386 arch
RUN dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get -y install software-properties-common \
  && add-apt-repository -y ppa:guardianproject/fdroidserver \
  && apt-get update \
  && apt-get install -q -y  fdroidserver \
     default-jdk-headless \
  && rm -rf /var/lib/apt/lists/*


ADD cron.sh /bin/cron.sh
RUN chmod +x /bin/cron.sh
ADD raccoon-${RACCOON_VERSION}.jar /bin/raccoon.jar

VOLUME [/import.txt]
VOLUME [/raccoon]
VOLUME [/fdroid]

RUN echo "*	*/4	*	*	*	root	/bin/cron.sh" >> /etc/crontab

WORKDIR /fdroid
ENTRYPOINT ["cron","-f"]