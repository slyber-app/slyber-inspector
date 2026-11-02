FROM alpine:3.20

ARG TARGETARCH
ARG VERSION=v1.0.0

RUN apk add --no-cache ca-certificates tzdata && \
    addgroup -g 10001 -S slyber && \
    adduser -u 10001 -S -G slyber -H -s /sbin/nologin slyber

COPY bin/slyber_test-linux-${TARGETARCH} /usr/local/bin/slyber_test
RUN chmod +x /usr/local/bin/slyber_test

USER 10001:10001

ENV LISTEN_ADDR="0.0.0.0:8095"

EXPOSE 8095/tcp

ENTRYPOINT ["slyber_test"]