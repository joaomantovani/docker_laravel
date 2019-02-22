FROM php:7.3-apache

MAINTAINER Joao Pedro Mantovani <jpm.mantovani45@gmail.com>

RUN apt-get update -y && apt-get install -y openssl zip unzip git

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN docker-php-ext-install pdo mbstring

# Setup working directory
WORKDIR /var/www/html

ARG APACHE_USER=www-data

# Manually set up the apache environment variables
ENV APACHE_RUN_USER $APACHE_USER
ENV APACHE_RUN_GROUP $APACHE_USER
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN chown -R $APACHE_USER:$APACHE_USER /var/www/html

ADD httpd.conf /etc/apache2/sites-enabled/000-default.conf

CMD /usr/sbin/apache2ctl -D FOREGROUND

CMD php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000