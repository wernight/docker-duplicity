FROM alpine:3.3

RUN apk add --update duplicity

CMD ["duplicity"]
