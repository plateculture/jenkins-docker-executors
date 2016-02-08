FROM ubuntu:trusty
MAINTAINER Alex Sanz <asans@evirtualpost.com>

# expose the port
EXPOSE 8080
# required to make docker in docker to work
VOLUME /var/lib/docker

# default jenkins home directory
ENV JENKINS_HOME /var/jenkins
# set our user home to the same location
ENV HOME /var/jenkins

# set our wrapper
ENTRYPOINT ["/usr/local/bin/docker-wrapper"]
# default command to launch jenkins
CMD java -jar /usr/share/jenkins/jenkins.war

# setup our local files first
ADD docker-wrapper.sh /usr/local/bin/docker-wrapper

# now we install docker in docker - thanks to https://github.com/jpetazzo/dind
# We install newest docker into our docker in docker container
ADD https://get.docker.io/builds/Linux/x86_64/docker-1.6.2 /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker

# for installing docker related files first
RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
# apparmor is required to run docker server within docker container
RUN apt-get update -qq && apt-get install -qqy wget curl git iptables ca-certificates apparmor

# for jenkins
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list \
    && wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update -qq && apt-get install -qqy jenkins

RUN apt-get update && apt-get install -qy \
  git \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libpq-dev \
  imagemagick \
  libmagickwand-dev \
  cmake \
  nodejs \
  curl \
  aspell \
  aspell-en \
  wget \
  gzip

RUN cd /tmp && \
  git clone https://github.com/sstephenson/ruby-build.git && \
  cd ruby-build && \
  ./install.sh && \
  ruby-build 2.3.0 /opt/ruby/2.3.0 && \
  rm -rf /tmp/ruby-build*

ENV PATH=$PATH:/opt/ruby/2.3.0/bin

RUN gem update --system && \
    gem install bundler
