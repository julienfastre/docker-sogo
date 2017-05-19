FROM ubuntu:16.04

MAINTAINER Julien Fastré <julienfastre@cvfe.be>

ARG version=3.2.9

WORKDIR /tmp/build

# download SOPE sources
ADD https://github.com/inverse-inc/sope/archive/SOPE-${version}.tar.gz /tmp/src/sope/sope.tar.gz

# download sogo sources
ADD https://github.com/inverse-inc/sogo/archive/SOGo-${version}.tar.gz /tmp/src/SOGo/SOGo.tar.gz

# prepare & compile
RUN echo "untar SOPE sources" \
   && tar -xf /tmp/src/sope/sope.tar.gz && mkdir /tmp/SOPE && mv sope-SOPE-${version}/* /tmp/SOPE/. \
   && echo "untar SOGO sources"  \
   && tar -xf /tmp/src/SOGo/SOGo.tar.gz && mkdir /tmp/SOGo && mv sogo-SOGo-${version}/* /tmp/SOGo/. \ 
   && echo "install required packages" \
   && apt-get update  \
   && apt-get install -qy --no-install-recommends \
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
      libcurl4-openssl-dev \
      tzdata \
   && echo "compiling sope & sogo" \
   && cd /tmp/SOPE  \
   && ./configure --with-gnustep --enable-debug --disable-strip  \
   && make  \
   && make install  \
   && cd /tmp/SOGo  \
   && ./configure --enable-debug --disable-strip  \
   && make  \
   && make install \
   && echo "register sogo library" \
   && echo "/usr/local/lib/sogo" > /etc/ld.so.conf.d/sogo.conf  \
   && ldconfig \
   && echo "create user sogo" \
   && groupadd --system sogo && useradd --system --gid sogo sogo \
   && echo "create directories and enforce permissions" \
   && install -o sogo -g sogo -m 755 -d /var/run/sogo  \
   && install -o sogo -g sogo -m 750 -d /var/spool/sogo  \
   && install -o sogo -g sogo -m 750 -d /var/log/sogo
   
# add sogo.conf
ADD sogo.default.conf /etc/sogo/sogo.conf

VOLUME /usr/local/lib/GNUstep/SOGo/WebServerResources

EXPOSE 20000

USER sogo

# load env
RUN . /usr/share/GNUstep/Makefiles/GNUstep.sh

CMD [ "sogod", "-WONoDetach", "YES", "-WOPort", "20000", "-WOLogFile", "-", "-WOPidFile", "/tmp/sogo.pid"]

