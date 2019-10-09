FROM alpine:3.10.2
LABEL author="Sergey Bovyrin <sbovyrin@gmail.com>" \
    description="Tiny lightweight image with PHP-7. By default entry file folder is '/web'" \
    arguments="TIMEZONE pass your timezone e.g: GMT0" \
    extensions="Call 'php -m' to find out isntalled extensions" \
    version="1.1.0"

ARG TIMEZONE="GMT0"
ENV DEPS="tzdata curl"
ENV RUNTIME_DEPS="php7 php7-curl php7-ctype php7-dom php7-fileinfo php7-ftp php7-iconv php7-json php7-mbstring php7-openssl php7-phar php7-posix php7-session php7-tokenizer php7-xml"
ENV COMPOSER_GLOBAL_PATH="/opt/composer"
ENV PATH="${PATH}:${COMPOSER_GLOBAL_PATH}/vendor/bin"

RUN apk add --no-cache $RUNTIME_DEPS $DEPS \
    && mkdir -p $COMPOSER_GLOBAL_PATH \
    && curl -sS https://getcomposer.org/installer \
        | php -- --install-dir=/usr/bin --filename=composer \
    && composer --no-cache --working-dir=$COMPOSER_GLOBAL_PATH require friendsofphp/php-cs-fixer phan/phan \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apk del --purge $DEPS \
    && addgroup -g 1000 -S www-data \
    && adduser -u 1000 -S www-data -G www-data

USER www-data
WORKDIR /var/www/html
EXPOSE 9000
CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]
