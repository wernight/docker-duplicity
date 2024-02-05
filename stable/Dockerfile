FROM alpine:3.19

ENV HOME=/home/duplicity

RUN apk add --no-cache duplicity

RUN set -x \
    # Run as non-root user.
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/

VOLUME ["/home/duplicity/.cache/duplicity", "/home/duplicity/.gnupg"]

USER duplicity

# Brief check that it works.
RUN duplicity --version

CMD ["duplicity"]
