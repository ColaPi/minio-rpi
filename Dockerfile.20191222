FROM balenalib/armv7hf-alpine:latest-run

EXPOSE 9000

RUN \ 
    apk add --update curl ca-certificates &&  \
    curl -sSLO https://dl.minio.io/server/minio/release/linux-arm/minio && \
    mv minio /usr/local/bin/ &&\
    chmod +x /usr/local/bin/minio

ENTRYPOINT ["/usr/local/bin/minio"]
