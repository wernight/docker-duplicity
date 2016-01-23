FROM alpine:3.3

RUN apk add --update duplicity openssh openssl py-crypto py-pip rsync \
 && pip install pydrive==1.0.1 \
 && apk del --purge py-pip \
 && rm /var/cache/apk/* \
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && chmod go+rwx /home/duplicity/.cache/duplicity

ENV HOME=/home/duplicity

VOLUME /home/duplicity/.cache/duplicity

USER duplicity
 
CMD ["duplicity"]
