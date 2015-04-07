FROM ubuntu:precise

MAINTAINER Shane Dowling, shane@shanedowling.com

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV HOME /root

ENV DEBIAN_FRONTEND noninteractive
# Utilities and Apache, PHP
RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe main multiverse restricted" > /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise-security universe main multiverse restricted" >> /etc/apt/sources.list
RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get -y install git subversion curl apache2 php5 php5-cli libapache2-mod-php5 php5-mysql php-apc php5-gd php5-curl php5-memcached php5-mcrypt php5-sqlite mysql-client php5-ldap php5-imap php5-cgi php5-dev php-pear php5-xdebug&&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN sed -i -r 's/AllowOverride None$/AllowOverride All/' /etc/apache2/sites-available/default

# PHP prod config
ADD files/php.ini /etc/php5/apache2/php.ini
ADD files/vhost.conf /etc/apache2/sites-available/sugarcrm

# Ensure PHP log file exists and is writable
RUN touch /var/log/php_errors.log && chmod a+w /var/log/php_errors.log

# Our start-up script
ADD files/start.sh /start.sh
RUN chmod a+x /start.sh

# Turn on some crucial apache mods
RUN a2enmod rewrite headers filter

RUN a2ensite sugarcrm

RUN apache2ctl restart

VOLUME ["/var/www/sugarcrm"]
VOLUME ["/var/log"]

ENTRYPOINT ["/start.sh"]
EXPOSE 80
