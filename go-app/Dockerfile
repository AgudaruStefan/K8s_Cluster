FROM golang:1.17-alpine3.15


WORKDIR /app


COPY . .


RUN go mod init


RUN go build -o main .


FROM alpine:3.15


COPY --from=0 /app/main /app/main


CMD ["/app/main"]
