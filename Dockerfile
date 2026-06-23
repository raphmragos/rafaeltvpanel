FROM openresty/openresty:alpine

# Mag-install ng mga kailangang pakete
RUN apk add --no-cache ca-certificates wget unzip tini

# Mag-download at mag-install ng Xray kasama ang mga database files
RUN wget -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip

# Kopyahin ang mga configuration files
COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

# Mag-set ng tamang path para mabasa ng Xray ang geo files
ENV XRAY_LOCATION_ASSET=/usr/local/share/xray/

EXPOSE 8080

# Gamitin ang tini para pamahalaan ang maraming proseso nang maayos
ENTRYPOINT ["/sbin/tini", "--"]
CMD sh -c "/usr/local/bin/xray run -c /etc/xray.json & exec /usr/local/openresty/bin/openresty -g 'daemon off;'"
