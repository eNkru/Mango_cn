FROM crystallang/crystal:1.20.0-alpine AS builder

WORKDIR /Mango

COPY . .
RUN apk add --no-cache ca-certificates yarn make wget gcc musl-dev gmp-static yaml-static sqlite-static sqlite-dev libarchive-dev libarchive-static acl-static expat-static zstd-static lz4-static bzip2-static libjpeg-turbo-dev libpng-dev tiff-dev libwebp-dev libwebp-static
RUN make static || make static

FROM library/alpine

WORKDIR /

COPY --from=builder /Mango/mango .

CMD ["./mango"]
