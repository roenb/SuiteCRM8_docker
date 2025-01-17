FROM ubuntu:latest

LABEL org.opencontainers.image.authors="jon@titmus.me"

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt -y upgrade
RUN apt-get install vim -y
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get install apache2 -y

RUN apt -y install ca-certificates apt-transport-https software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get -y update
RUN apt-get install -y php7.4 libapache2-mod-php7.4
RUN apt-get install -y php7.4-fpm libapache2-mod-fcgid
RUN apt-get install -y php7.4-mysql
RUN apt-get install -y php7.4-curl php7.4-intl php7.4-zip php7.4-imap php7.4-gd

RUN a2enmod rewrite
RUN a2enmod php7.4
RUN a2enconf php7.4-fpm

RUN apt install -y php7.4-xml php7.4-mbstring
RUN apt install -y zlib1g-dev libxml2-dev

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs \
    npm

RUN npm install -g @angular/cli
RUN npm install --global yarn

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Install PHP LDAP extension
RUN apt-get install -y php7.4-ldap

RUN apt-get install -y mysql-client
# Install OpenSSL
RUN apt-get install -y openssl

# Enable SSL module in Apache
RUN a2enmod ssl

# Change the document root of Apache to /var/www/html/SuiteCRM
# RUN sed -i 's|/var/www/html|/var/www/html/SuiteCRM|g' /etc/apache2/sites-available/000-default.conf

# # Set ownership for the SuiteCRM directory
# RUN chown -R www-data:www-data /var/www/html

# # Set permissions for directories and files within SuiteCRM
# RUN find /var/www/html -type d -exec chmod 775 {} \;
# RUN find /var/www/html -type f -exec chmod 664 {} \;



# Disable the default site
RUN a2dissite 000-default.conf

# Add custom site configuration
COPY ./docker/config/apache/sites.conf /etc/apache2/sites-available/suitecrm.conf
RUN a2ensite suitecrm.conf

# Optionally remove the default config if it's not needed
RUN rm /etc/apache2/sites-available/000-default.conf

# Add an entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]


EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
