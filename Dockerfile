FROM tiredofit/alpine:edge as builder
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

RUN set -x && \
    ## Add Dependencies
    apk update && \
    apk add -t .mongodb-build-deps \
               alpine-sdk \
               && \
    \
    ## Create User for Building
    adduser  -G abuild -g "Alpine Package Builder" -s /bin/ash -u 32767 -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /usr/src/aports && \
    chown builder:abuild /usr/src/aports && \
    ## Generate Keys
    sudo -u builder abuild-keygen -a -i -n && \
    cd /usr/src/aports && \
    \
    ## Checkout only the following package directories
    sudo -u builder git init && \
    sudo -u builder git remote add origin -f https://github.com/alpinelinux/aports.git && \
    sudo -u builder git config core.sparsecheckout true && \
    sudo -u builder echo "non-free/mongo-c-driver/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/mongodb/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/mongodb-tools/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/php7-pecl-mongodb/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/py-flask-mongoengine/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/py-flask-pymongo/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/py-flask-views/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/py-mongo/*" >> .git/info/sparse-checkout && \
    sudo -u builder echo "non-free/wiredtiger/*" >> .git/info/sparse-checkout && \
    sudo -u builder git pull --depth=1 origin master && \
    \
    cd non-free && \
    ## Build Tools
    cd mongodb && \
    sudo -u builder abuild -r && \
    cd ../mongodb-tools && \
    sudo -u builder abuild -r && \
    cd ../mongo-c-driver && \
    sudo -u builder abuild -r && \
    cd ../php7-pecl-mongodb && \
    sudo -u builder abuild -r && \
    cd ../py-flask-mongoengine && \
    sudo -u builder abuild -r && \
    cd ../py-flask-pymongo && \
    sudo -u builder abuild -r && \
    cd ../py-flask-views && \
    sudo -u builder abuild -r && \
    cd ../wiredtiger && \
    sudo -u builder abuild -r

FROM scratch
COPY --from=builder /home/builder/packages/non-free/x86_64/ /
