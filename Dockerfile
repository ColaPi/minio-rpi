FROM resin/raspberrypi3-golang:1.10.4

ENV GOPATH /go
ENV CGO_ENABLED 0

WORKDIR /go/src/github.com/minio/
RUN \
go get -v -d github.com/minio/minio && \
cd /go/src/github.com/minio/minio && \
go install -v -ldflags "$(go run buildscripts/gen-ldflags.go)" 

FROM resin/raspberrypi3-alpine
ENV MINIO_UPDATE off
ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key

EXPOSE 9000

COPY --from=0 /go/bin/minio /usr/bin/minio
ADD https://raw.githubusercontent.com/minio/minio/master/dockerscripts/docker-entrypoint.sh /usr/bin/
ADD https://raw.githubusercontent.com/minio/minio/master/dockerscripts/healthcheck.sh /usr/bin/
RUN \ 
apk add --no-cache ca-certificates 'curl>7.61.0' && \
echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s \
CMD /usr/bin/healthcheck.sh

CMD ["minio"]
