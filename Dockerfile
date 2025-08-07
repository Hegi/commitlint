FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -X=main.Version=docker" \
    -o commitlint \
    ./cmd/commitlint/main.go

FROM alpine:latest

COPY --from=builder /app/commitlint /usr/local/bin/commitlint
WORKDIR /workspace
RUN adduser -D -s /bin/sh commitlint && \
    chown commitlint:commitlint /usr/local/bin/commitlint && \
    chmod +x /usr/local/bin/commitlint

USER commitlint

ENTRYPOINT ["commitlint"]
CMD ["--help"]
