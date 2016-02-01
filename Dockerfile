FROM alpine:3.3

RUN apk add --update duplicity openssh openssl py-crypto py-pip rsync \
 && pip install pydrive==1.0.1 \
 && apk del --purge py-pip \
 && rm /var/cache/apk/* \
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/

ENV HOME=/home/duplicity

VOLUME /home/duplicity/.cache/duplicity
VOLUME /home/duplicity/.gnupg

USER duplicity
 
CMD ["duplicity"]
