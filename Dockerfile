FROM ubuntu:16.04

MAINTAINER Julien Fastré <julienfastre@cvfe.be>

ARG version=3.1.4

# download SOPE sources
WORKDIR /tmp/src/sope
ADD https://github.com/inverse-inc/sope/archive/SOPE-${version}.tar.gz .
RUN tar -xf SOPE-${version}.tar.gz && mkdir /tmp/SOPE && mv sope-SOPE-${version}/* /tmp/SOPE/.

# download sogo sources
WORKDIR /tmp/src/SOGo
ADD https://github.com/inverse-inc/sogo/archive/SOGo-${version}.tar.gz .
RUN tar -xf SOGo-${version}.tar.gz && mkdir /tmp/SOGo && mv sogo-SOGo-${version}/* /tmp/SOGo/.

RUN apt-get update && \
   apt-get install -qy --no-install-recommends \
      gnustep-make \
      gnustep-base-common \
      libgnustep-base-dev \
      make \
      gobjc \
      libxml2-dev \
      libssl-dev \
      libldap2-dev \
      postgresql-server-dev-9.5 \
      libmemcached-dev \
      libcurl4-openssl-dev



# compiling sope & sogo
RUN cd /tmp/SOPE && \
   ./configure --with-gnustep --enable-debug --disable-strip && \
   make && \
   make install && \
   cd /tmp/SOGo && \
   ./configure --enable-debug --disable-strip && \
   make && \
   make install
   
   
# register sogo library
RUN echo "/usr/local/lib/sogo" > /etc/ld.so.conf.d/sogo.conf && \
   ldconfig

# create sogo user
RUN groupadd --system sogo && useradd --system --gid sogo sogo

# create directories
# Enforce directory existence and permissions
RUN install -o sogo -g sogo -m 755 -d /var/run/sogo && \
   install -o sogo -g sogo -m 750 -d /var/spool/sogo && \
   install -o sogo -g sogo -m 750 -d /var/log/sogo
   
# add sogo.conf
ADD sogo.default.conf /etc/sogo/sogo.conf

EXPOSE 20000

USER sogo

# load env
RUN . /usr/share/GNUstep/Makefiles/GNUstep.sh

CMD [ "sogod", "-WONoDetach", "YES", "-WOPort", "20000", "-WOLogFile", "-", "-WOPidFile", "/tmp/sogo.pid"]

