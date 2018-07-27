# https://hub.docker.com/r/czerasz/nginx-geoip2/
FROM nginx:1.15.1

LABEL maintainer="Michał Czeraszkiewicz <contact@czerasz.com>,Miguel David <miguel.david@wikitribune.com>"

# Update system and install required software
RUN apt-get update &&\
    apt-get install -y wget vim \
    curl \
    git \
    build-essential \
    autoconf \
    libtool \
    libpcre3 \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev

# Download MaxMind GeoLite2 databases
RUN mkdir -p /usr/share/GeoIP/ &&\
    wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz &&\
    gunzip GeoLite2-City.mmdb.gz &&\
    mv GeoLite2-City.mmdb /usr/share/GeoIP/ &&\
    wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz &&\
    gunzip GeoLite2-Country.mmdb.gz &&\
    mv GeoLite2-Country.mmdb /usr/share/GeoIP/

# Install C library for reading MaxMind DB files
# Resource: https://github.com/maxmind/libmaxminddb
RUN git clone --recursive https://github.com/maxmind/libmaxminddb.git &&\
    cd libmaxminddb &&\
    ./bootstrap &&\
    ./configure &&\
    make &&\
    make check &&\
    make install &&\
    echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf &&\
    ldconfig

# Download Nginx and the Nginx geoip2 module
ENV nginx_version 1.15.1
RUN curl http://nginx.org/download/nginx-$nginx_version.tar.gz | tar xz &&\
    git clone https://github.com/leev/ngx_http_geoip2_module.git

WORKDIR /nginx-$nginx_version

# Compile Nginx
RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
    --add-dynamic-module=/ngx_http_geoip2_module &&\
    make &&\
    make install

RUN rm -rf /nginx-$nginx_version /libmaxminddb /ngx_http_geoip2_module
WORKDIR /
COPY nginx.conf /etc/nginx/nginx.conf