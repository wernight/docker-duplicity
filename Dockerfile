FROM alpine:3.3

RUN apk add --update duplicity py-pip \
 && pip install pydrive==1.0.1 \
 && apk del --purge py-pip \
 && rm /var/cache/apk/* \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && chmod go+rwx /home/duplicity/.cache/duplicity

ENV HOME=/home/duplicity

VOLUME /home/duplicity/.cache/duplicity
 
CMD ["duplicity"]
