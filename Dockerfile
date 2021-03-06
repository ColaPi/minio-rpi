FROM balenalib/raspberrypi3-golang:latest-build

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on
ENV GOPROXY https://proxy.golang.org

ENV VERSION RELEASE.2020-01-16T22-40-29Z

RUN  \
     git clone --branch $VERSION https://github.com/minio/minio && cd minio && \
     go install -v -ldflags "$(go run buildscripts/gen-ldflags.go)"


FROM balenalib/raspberrypi3-alpine:latest-run

ENV MINIO_UPDATE off
ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_SSE_MASTER_KEY_FILE=sse_master_key

EXPOSE 9000

COPY --from=0 /go/bin/minio /usr/bin/minio
ADD https://raw.githubusercontent.com/minio/minio/master/dockerscripts/docker-entrypoint.sh /usr/bin/

RUN  \
     chmod +x /usr/bin/docker-entrypoint.sh &&\
     apk add --no-cache ca-certificates 'curl>7.61.0' 'su-exec>=0.2' && \
     echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

VOLUME ["/data"]

CMD ["minio"]
