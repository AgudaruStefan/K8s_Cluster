
FROM golang:1.17-alpine3.15

WORKDIR /app

COPY . .

RUN cd go-app && go mod init 

RUN cd go-app && go build -o main .

FROM alpine:3.15

COPY --from=0 /app/go-app/main /app/main

CMD ["/app/main"]
