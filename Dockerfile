FROM php:7.3.8-cli-alpine3.10 AS builder

ARG tarball_url="https://github.com/felixfbecker/php-language-server/archive/master.tar.gz"
ENV LOCAL_BIN_DIR="/usr/local/bin"
ENV PATH="$LOCAL_BIN_DIR:$PATH"
ENV APP_DIR=/app

WORKDIR $APP_DIR

COPY composer-installer $LOCAL_BIN_DIR

RUN (set -eux -o pipefail \
	&& curl -L "$tarball_url" | tar -zxv --strip-components=1 \
	&& composer-installer --filename=composer --install-dir=$LOCAL_BIN_DIR \
	&& composer install --no-dev --optimize-autoloader --prefer-dist)

RUN docker-php-ext-install pcntl

FROM php:7.3.8-cli-alpine3.10

LABEL maintainer="Gasol Wu <gasol.wu@gmail.com>"

ENV APP_DIR=/app
ENV PHP_EXT_DIR=/usr/local/lib/php/extensions/no-debug-non-zts-20180731

RUN set -eux && addgroup -g 1000 -S php && adduser -u 1000 -S -G php php

COPY --from=builder --chown=php:php "$APP_DIR" "$APP_DIR"
COPY --from=builder ${PHP_EXT_DIR}/pcntl.so ${PHP_EXT_DIR}/
COPY --from=builder ${PHP_INI_DIR}/conf.d/docker-php-ext-pcntl.ini ${PHP_INI_DIR}/conf.d/

USER php

WORKDIR $APP_DIR

EXPOSE 22088

CMD ["--tcp-server=0:22088"]

ENTRYPOINT ["php", "bin/php-language-server.php"]
