FROM alpine

RUN apk --no-cache add \
        bash \
        curl \
        openssl

ADD upload.sh s3-upload.sh /bin/
RUN chmod +x /bin/*.sh

ENTRYPOINT /bin/upload.sh
