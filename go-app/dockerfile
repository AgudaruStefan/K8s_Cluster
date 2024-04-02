
FROM golang:1.17 AS build

WORKDIR /app
COPY . .

RUN go build -o main .

FROM alpine:3.15

WORKDIR /root/
COPY --from=build /app/main .

EXPOSE 8080

CMD ["./main"]
