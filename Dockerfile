FROM phusion/baseimage:0.9.17
MAINTAINER Ariel Abrams-Kudan <arielak@mitre.org>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install ssmtp apache2-utils git apache2 curl php5-gd libapache2-mod-php5 mysql-server php5-mysql php5-curl pwgen php-apc php5-mcrypt php-apc && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
RUN mkdir /etc/sv/apache2
ADD start-apache2.sh /etc/sv/apache2/run
RUN chmod +x /etc/sv/apache2/run

ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN mkdir /etc/service/mysql
ADD start-mysqld.sh /etc/service/mysql/run
RUN chmod +x /etc/service/mysql/run

# Fix sendmail with ssmtp
ADD sendmail.ini /etc/php5/mods-available/sendmail.ini
RUN php5enmod sendmail
ADD rewrite-sendmail.sh /rewrite-sendmail.sh

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Create a space for Elgg
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Translate all git:// to https://
# Thank you http://stackoverflow.com/questions/15903275/git-is-blocked-how-to-install-npm-modules
RUN git config --global url."https://".insteadOf git://

# Media directory is the data directory
RUN chown -R www-data:www-data /media

# Environment variables to configure php and elgg
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Fix perms on scripts
RUN chmod 755 /*.sh

# clean up tmp files (we don't need them for the image)
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
