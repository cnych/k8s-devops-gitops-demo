FROM golang:1.20.1-alpine
WORKDIR /home
COPY go.mod go.sum main.go ./
RUN go version
RUN go env -w GOPROXY=https://goproxy.io
RUN GOOS=linux GOARCH=amd64 go build -v -o demo-app

FROM alpine:3.16.2

WORKDIR /home

# 修改alpine源为阿里云
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
  apk update && \
  apk upgrade && \
  apk add ca-certificates && update-ca-certificates && \
  apk add --update tzdata && \
  rm -rf /var/cache/apk/*

COPY --from=0 /home/demo-app /home/
ENV TZ=Asia/Shanghai

EXPOSE 8080

ENTRYPOINT ./demo-app

