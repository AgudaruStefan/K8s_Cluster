# Use the official Golang image
FROM golang:1.17-alpine3.15 AS builder

# Set the current working directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go-app/go.mod go-app/go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN go build -o main .

# Use a minimal alpine image to run the application
FROM alpine:3.15

WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/main .

# Expose port 8080
EXPOSE 8080

# Command to run the application
CMD ["./main"]
