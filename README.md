Dockerfile to build MongoDB and associated non-free tools for Alpine for use in other images

Recently Alpine Linux removed the following MongoDB packages from it's `edge` repository.

* `mongo-c-driver`
* `mongodb`
* `mongodb-tools`
* `php7-pecl-mongodb`
* `py-flask-mongoengine`
* `py-flask-pymongo`
* `py-flask-views`
* `py-mongo`
* `wiredtiger`

This image will take a long time to build, and the end result is a series of .apk files that you can install in another image.
To utilize, take advantage of Docker's Multistage build process as follows:

```bash
FROM tiredofit/mongo-builder as mongo-packages
FROM tiredofit/alpine:edge
COPY --from=mongo-packages / /usr/src/apk

RUN apk update && \
    cd /usr/src/apk && \
    apk add --allow-untrusted <yourpackagename>.apk
    ... the rest of your Docker Build
```
