FROM golang:1.26-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir -p internal/webui/dist/assets && \
    printf '<!doctype html><html><head><meta charset="utf-8"><title>CPAB</title></head><body><h1>CLIProxyAPIBusiness v7</h1><p>API-only deployment. Use API endpoints directly.</p></body></html>' > internal/webui/dist/index.html && \
    printf '/* placeholder */' > internal/webui/dist/assets/app.js

RUN CGO_ENABLED=0 go build -trimpath \
    -ldflags "-s -w -X main.Version=v7-sdk -X main.Commit=$(git rev-parse --short HEAD 2>/dev/null || echo unknown) -X main.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    -o /cpab ./cmd/business

FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /CLIProxyAPIBusiness

COPY --from=builder /cpab ./cpab

EXPOSE 8318

CMD ["./cpab"]
