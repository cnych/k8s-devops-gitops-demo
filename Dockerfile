FROM golang:latest AS build
RUN mkdir -p drone-k8s
ADD . drone-k8s
WORKDIR drone-k8s
RUN export GOPROXY="https://goproxy.io" && CGO_ENABLED=0 go build -o /demo-app

FROM alpine

WORKDIR /home

RUN apk update && \
  apk upgrade && \
  apk add ca-certificates && update-ca-certificates && \
  apk add --update tzdata && \
  rm -rf /var/cache/apk/*

COPY --from=build /demo-app /home/
ENV TZ=Asia/Shanghai

EXPOSE 8080

ENTRYPOINT ./demo-app
