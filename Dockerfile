FROM ubuntu:trusty
MAINTAINER Ariel Abrams-Kudan <arielak@mitre.org>

# Linux hosts with kernel > 3.15 have problems modifying users.
# This is the suggested fix
# See https://github.com/docker/docker/issues/6345
RUN mv /usr/bin/chfn /usr/bin/chfn.real && ln -s /bin/true /usr/bin/chfn

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor apache2-utils git apache2 curl php5-gd libapache2-mod-php5 mysql-server php5-mysql php5-curl pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# package install is finished, clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Create a space for Elgg
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

# Install Composer. We run it in run.sh so the /app volume is mounted
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Translate all git:// to https://
# Thank you http://stackoverflow.com/questions/15903275/git-is-blocked-how-to-install-npm-modules
RUN git config --global url."https://".insteadOf git://

# Media directory is the data directory
RUN chown -R www-data:www-data /media

# Environment variables to configure php and elgg
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# clean up tmp files (we don't need them for the image)
RUN rm -rf /tmp/* /var/tmp/*
