# Supported tags and respective `Dockerfile` links

- `3.1.4`, `3.1`, `latest`


# What is SOGo ?

SOGo (formerly named Scalable OpenGroupware.org) is an open source collaborative software (groupware) server with a focus on simplicity and scalability. It is developed in Objective-C using PostgreSQL, Apache, and IMAP.

SOGo provides collaboration for Mozilla Thunderbird/Lightning, Microsoft Outlook, Apple iCal/iPhone and BlackBerry client users. Its features include the ability to share calendars, address books and e-mail using an open source, cross-platform environment. The Funambol middleware and the Funambol SOGo Connector allow SyncML clients to synchronize contacts, events and tasks.

SOGo supports standard groupware capabilities including CalDAV, CalDAV auto-scheduling, CardDAV, WebDAV Sync, WebDAV ACLs, and iCalendar.

Microsoft Outlook support is provided through an OpenChange storage provider to remove the MAPI dependency for sharing address books, calendars and e-mails. Native connectivity to Microsoft Outlook allows SOGo to emulate a Microsoft Exchange server to Outlook clients.

(source : Wikipedia contributors, "SOGo," Wikipedia, The Free Encyclopedia, https://en.wikipedia.org/w/index.php?title=SOGo&oldid=731475399 (accessed August 5, 2016). )

# Use with care and contribute to Inverse Inc

This image is still experimental. Use with care.

Since July 2016, Inverse Inc. [ask for some support](https://sogo.nu/nc/support/faq/article/why-production-packages-required-a-support-contract-from-inverse.html) to provide debian packages. This should help them to increase their investments in SOGo. If you can afford [this](https://sogo.nu/support/index_new.html#/commercial), you should consider getting support on Inverse Inc.

# How to use this image

The requires :

- a working IMAP and SMTP server (not provided under docker container) ;
- a postgresql / mysql database ;
- memcached ;
- some way to authenticate user: LDAP, SQL table, ... (see [the docs](SOGoInstallationGuide.pdf))

Using the pattern one container = one process, this container only execute the `sogod` process.

In order to run it You should create an adapt a config file to your needs, [using the docs](SOGoInstallationGuide.pdf). This file should be recorded into the container as `/etc/sogo/sogo.conf`.

## Using docker-compose

This is a `docker-compose.yml` file you could adapt to launch this image :

```

version: '2'

services:
   sogo:
# if you prefer building by yourself
#      build: 
#         context: .
#         args:
#            version: 2.2.13
# if you prefer using an image
      image: julienfastre/sogo:3.1.4
      links: 
         - db
      volumes:
         # required to allow nginx to access to resources
         - /usr/local/lib/GNUstep/SOGo/WebServerResources/
         # create 
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
         - sogo:ro
      ports:
         - "8080:80"
      volumes: 
         - ./nginx.conf:/etc/nginx/nginx.conf:ro

```

You should then be able to reach sogo on http://localhost:8080/SOGo.

**Warning** after login, the redirection does not work and you will reach http://localhost/SOGo/<your path> instead of http://localhost:8080/SOGo/<your path>. Simply add the missing port part.

