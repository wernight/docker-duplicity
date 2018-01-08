FROM alpine:3.7

ENV HOME=/home/duplicity

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
 && pip install \
      pydrive==1.3.1 \
      fasteners==0.14.1 \
 && apk del --purge py-pip \
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/ \
 && su - duplicity -c 'duplicity --version'

VOLUME ["/home/duplicity/.cache/duplicity", "/home/duplicity/.gnupg"]

USER duplicity
 
CMD ["duplicity"]
