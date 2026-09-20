FROM eceasy/cli-proxy-api-business:latest AS web-assets

FROM golang:1.26-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

COPY --from=web-assets /CLIProxyAPIBusiness/web/dist internal/webui/dist

RUN CGO_ENABLED=0 go build -trimpath \
    -ldflags "-s -w -X main.Version=v7-sdk -X main.Commit=$(git rev-parse --short HEAD 2>/dev/null || echo unknown) -X main.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    -o /cpab ./cmd/business

FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /CLIProxyAPIBusiness

COPY --from=builder /cpab ./cpab

EXPOSE 8318

CMD ["./cpab"]
