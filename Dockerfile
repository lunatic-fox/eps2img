FROM alpine:latest
RUN apk --no-cache add bash ghostscript
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
