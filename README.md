# What is SOGo ?

SOGo (formerly named Scalable OpenGroupware.org) is an open source collaborative software (groupware) server with a focus on simplicity and scalability. It is developed in Objective-C using PostgreSQL, Apache, and IMAP.

SOGo provides collaboration for Mozilla Thunderbird/Lightning, Microsoft Outlook, Apple iCal/iPhone and BlackBerry client users. Its features include the ability to share calendars, address books and e-mail using an open source, cross-platform environment. The Funambol middleware and the Funambol SOGo Connector allow SyncML clients to synchronize contacts, events and tasks.

SOGo supports standard groupware capabilities including CalDAV, CalDAV auto-scheduling, CardDAV, WebDAV Sync, WebDAV ACLs, and iCalendar.

Microsoft Outlook support is provided through an OpenChange storage provider to remove the MAPI dependency for sharing address books, calendars and e-mails. Native connectivity to Microsoft Outlook allows SOGo to emulate a Microsoft Exchange server to Outlook clients.

(source : Wikipedia contributors, "SOGo," Wikipedia, The Free Encyclopedia, https://en.wikipedia.org/w/index.php?title=SOGo&oldid=731475399 (accessed August 5, 2016). )

# Use with care and contribute to Inverse Inc

This image is in use in a organization of 80 people, without any known problem (except when we migrated from 2.3 to 3.2, see above).

Since July 2016, Inverse Inc. [ask for some support](https://sogo.nu/nc/support/faq/article/why-production-packages-required-a-support-contract-from-inverse.html) to provide debian packages. This should help them to increase their investments in SOGo. If you can afford [this](https://sogo.nu/support/index_new.html#/commercial), you should consider getting support on Inverse Inc.

# How to use this image

This image requires :

- a working IMAP and SMTP server (not provided under docker container) ;
- a postgresql / mysql database ;
- memcached ;
- some way to authenticate user: LDAP, SQL table, ... (see [the docs](SOGoInstallationGuide.pdf))
- a configuration file

This container only execute the `sogod` process, [taking into account the best practice "running one process per container"](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#/run-only-one-process-per-container).

In order to run it You should create an adapt a config file to your needs, [using the docs](SOGoInstallationGuide.pdf). This file should be recorded into the container as `/etc/sogo/sogo.conf`.

## Using the command line

**TO BE DONE**

## Using docker-compose

This is a `docker-compose.yml` file you could adapt to launch this image :

**Note** : the docker compose file in this project can be used, but it is using a non-standard port. After login, if you use a different port thant port 80, the redirection will not work and you will be redirected to `http://localhost/SOGo/<your path>` instead of `http://localhost:8080/SOGo/<your path>`. Simply add the missing port part (replace `http://localhost/SOGo` by `http://localhost:8080/SOGo`).



```

version: '2'

services:
   sogo:
# if you prefer building by yourself
      build: 
         context: .
         args:
         # replace by your desired  version
            version: x.x.x
# if you prefer using a pre-built image (replace by your desired version)
#      image: julienfastre/sogo:x.x
      links: 
         - db
      volumes:
         # replace by your own file
         - /path/to/your/file/sogo.conf:/etc/sogo/sogo.conf
   db:
      image: postgres:9.5
      # for debug purpose only: reach the database from outside
      #ports:
      #   - "5432"
   memcached:
      image: memcached:1.4-alpine
   nginx:
      image: nginx
      links:
         - sogo
      volumes_from:
         # you will be able to serve assets from sogo image
         - sogo:ro
      ports:
          # publish on port 80
          - "80:80"
          # if port 80 is already in use, **replace** by this line. (for testing only) Note that, after login, you will have to add the ":8080" in url
#         - "8080:80"
      volumes: 
         - ./nginx.conf:/etc/nginx/nginx.conf:ro

```

You should then be able to reach sogo on http://localhost:PORT/SOGo. Using the actual `nginx.conf` file **and** using a different port than the port 80 or 443, after login, you will encounter an http error on page `http://localhost/SOGo/<something>` Simply re-add the PORT number to reach correct server.

## How to build this image

The parameter `version` is required to build this image.

Example of how to build this image : 

```
# download sources
$ git clone https://framagit.org/julienfastre/docker-sogo.git
$ cd docker-sogo
# launch the build using the version 3.1.5
$ docker build --build-arg version=3.1.5 .
```

## migrating from 2.3 to 3.1|3.2 using docker-compose

The assets (css, js, ...) are contained in a volume. Those assets are completely different from version 2.3 to version 3.1 and 3.2. If you used `docker-compose` and migrated from 2.3 to 3.2, you have to either :

- remove the volume containing those assets, to let a clean place for the asset for the new version.
- or use an anonymous volume, which will be re-created on each restart

## Usage of sendmail / `SOGoMailingMechanism`

Sendmail is not installed in this image: sogo must be able to send mails using a smtp server. The `sogo.conf` file must have the option `SOGoMailingMechanism` on `smtp`. See [the section "SMTP Server Configuration" of the sogo manual](https://sogo.nu/files/docs/SOGo%20Installation%20Guide.pdf#33).

## Bug report

Please reports bug on https://github.com/julienfastre/docker-sogo/issues

