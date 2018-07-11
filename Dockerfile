# php72-mssql-docker
FROM ubuntu:16.04
LABEL "Author"="Rudi Yu <rudiwyu@gmail.com>"

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
	curl apt-transport-https debconf-utils \
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers and tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# Locale
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y language-pack-en-base &&\
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# Install PHP 7.2
RUN apt-get update && apt-get install -y software-properties-common
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y php7.2-fpm
RUN apt-get install -y php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml

# PHP 7.2 SQLSRV PDO_SQLSRV
RUN pecl install sqlsrv-5.2.0 pdo_sqlsrv-5.2.0 
RUN echo extension=pdo_sqlsrv.so > /etc/php/7.2/cli/conf.d/pdo_sqlsrv.ini
RUN echo extension=pdo_sqlsrv.so > /etc/php/7.2/fpm/conf.d/pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so > /etc/php/7.2/cli/conf.d/sqlsrv.ini
RUN echo extension=sqlsrv.so > /etc/php/7.2/fpm/conf.d/sqlsrv.ini

# Get Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer