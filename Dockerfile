FROM alpine:3.5

RUN set -x \
 && apk add --no-cache \
        ca-certificates \
        duplicity \
        openssh \
        openssl \
        py-crypto \
        py-pip \
        py-paramiko \
        py-setuptools \
        rsync \
 && update-ca-certificates \
 && pip install pydrive==1.3.1 \
 && apk del --purge py-pip \
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/

ENV HOME=/home/duplicity

VOLUME ["/home/duplicity/.cache/duplicity", "/home/duplicity/.gnupg"]

USER duplicity
 
CMD ["duplicity"]
