ARG TARGETPLATFORM
ARG BUILDPLATFORM

FROM woodpeckerci/plugin-ready-release-go:1.0.3 as builder

LABEL author="Lukas Wingerberg"
LABEL author_email="h@xx0r.eu"
LABEL github_url="https://github.com/CrystalNET-org/plugin-ready-release-helm"

RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache upgrade && \
    apk add --update-cache --no-cache curl bash tzdata git make g++ automake autoconf libsodium-dev musl-dev go && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /temp/build /temp/out && \
    cd /temp/build && \
    git clone --depth=1 https://github.com/norwoodj/helm-docs.git && \
    cd helm-docs && \
    go build github.com/norwoodj/helm-docs/cmd/helm-docs && \
    ls /temp/build && \
    cd /temp/build

FROM woodpeckerci/plugin-ready-release-go:1.0.3 as image

COPY --from=builder /temp/build/helm-docs /usr/bin/

CMD ["/app/node_modules/.bin/tsx", "/app/src/run.ts"]