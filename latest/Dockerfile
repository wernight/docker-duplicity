FROM alpine:3.12

ENV HOME=/home/duplicity

RUN set -x \
 && apk add --no-cache \
        ca-certificates \
        duplicity \
        lftp \
        openssh \
        openssl \
        py3-crypto \
        py3-paramiko \
        py3-setuptools \
        py3-requests \
        py3-requests-oauthlib \
        rsync \
 && update-ca-certificates

COPY Pipfile Pipfile.lock /

RUN set -x \
    # Install Python dependencies.
 && wget https://bootstrap.pypa.io/get-pip.py -O- | python3 - \
 && pip install pipenv \
 && pipenv install --system --deploy --python=$(which python3) \
 && python3 -m pip uninstall -y pip pipenv setuptools

RUN set -x \
    # Run as non-root user.
 && adduser -D -u 1896 duplicity \
 && mkdir -p /home/duplicity/.cache/duplicity \
 && mkdir -p /home/duplicity/.gnupg \
 && chmod -R go+rwx /home/duplicity/ \
    # Brief check that it works.
 && su - duplicity -c 'duplicity --version'

VOLUME ["/home/duplicity/.cache/duplicity", "/home/duplicity/.gnupg"]

USER duplicity
 
CMD ["duplicity"]
