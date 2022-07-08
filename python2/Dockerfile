# 3.15 is the last that has Python2.
FROM alpine:3.15

ENV HOME=/home/duplicity

RUN set -x \
 && apk add --no-cache \
        ca-certificates \
        gettext \
        gnupg \
        lftp \
        libffi \
        librsync \
        libxml2 \
        libxslt \
        openssh \
        openssl \
        python2 \
        rsync \
 && update-ca-certificates

COPY Pipfile Pipfile.lock /

RUN set -x \
    # Dependencies to build Python packages.
 && apk add --no-cache -t .build-deps \
        gcc \
        libffi-dev \
        librsync-dev \
        libxml2-dev \
        libxslt-dev \
        musl-dev \
        openssl-dev \
        python2-dev \
        py2-setuptools \
 && wget https://bootstrap.pypa.io/pip/2.7/get-pip.py -O- | python2 - \
 && pip install -U setuptools pip pipenv \
    # Install Python dependencies.
 && pipenv install --system --deploy \
    # Clean up
 && python2 -m pip uninstall -y pip pipenv setuptools \
 && apk del --purge .build-deps

RUN set -x \
    # Run as non-root user.
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/

RUN sed -i 's#/usr/bin/env python3#/usr/bin/env python2#' /usr/bin/duplicity

VOLUME ["/home/duplicity/.cache/duplicity", "/home/duplicity/.gnupg"]

USER duplicity

# Brief check that it works.
RUN duplicity --version
 
CMD ["duplicity"]
