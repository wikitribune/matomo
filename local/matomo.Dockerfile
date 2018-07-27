FROM matomo:fpm
LABEL maintainer="Miguel David <miguel.david@wikitribune.com>"

# Install C library for reading MaxMind DB files
# Resource: https://github.com/maxmind/libmaxminddb
RUN apt-get update && apt-get install git automake libtool -y
RUN cd / && git clone --recursive https://github.com/maxmind/libmaxminddb.git &&\
    cd libmaxminddb &&\
    ./bootstrap &&\
    ./configure &&\
    make &&\
    make check &&\
    make install &&\
    echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf &&\
    ldconfig &&\
    rm -rf /libmaxminddb

# Install MaxMind-DB-Reader-php extension
RUN cd / && apt-get update &&\
    apt-get install git &&\
    git clone https://github.com/maxmind/MaxMind-DB-Reader-php &&\
    cd MaxMind-DB-Reader-php/ &&\
    cd ext &&\
    phpize &&\
    ./configure &&\
    make &&\
    make install &&\
    rm -rf /MaxMind-DB-Reader-php &&\
    echo "extension=maxminddb.so" > /usr/local/etc/php/conf.d/matomo-maxmind.ini

COPY config.ini.php /var/www/html/config/config.ini.php
VOLUME ["/var/www/html"]