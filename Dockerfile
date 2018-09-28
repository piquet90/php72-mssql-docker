# php72-mssql-docker
FROM ubuntu:16.04
LABEL "Author"="Rudi Yu <rudiwyu@gmail.com>"

RUN `# Updating package list`                                                                                       && \
    apt-get update                                                                                                  && \
                                                                                                                       \
    `# Install util packages`                                                                                       && \
    apt-get install -y curl apt-transport-https debconf-utils language-pack-en-base unzip                           && \
    rm -rf /var/lib/apt/lists/*                                                                                     && \
                                                                                                                       \
    `# Add apt-key`                                                                                                 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -                                          && \
                                                                                                                       \
    `# Add mssql package list`                                                                                      && \
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list  && \
                                                                                                                       \
    `# Update package list`                                                                                         && \
    apt-get update                                                                                                  && \
                                                                                                                       \
    `# Install MSSQL ODBC`                                                                                          && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools unixodbc-dev software-properties-common                  && \
                                                                                                                       \
    `# Add binaries to path`                                                                                        && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc                                                    && \
                                                                                                                       \
    `# Source new paths`                                                                                            && \
    /bin/bash -c "source ~/.bashrc"                                                                                 && \
                                                                                                                       \
    `# Set locale`                                                                                                  && \
    export LC_ALL=en_US.UTF-8                                                                                       && \
                                                                                                                       \
    `# Set locale`                                                                                                  && \
    export LANG=en_US.UTF-8                                                                                         && \
                                                                                                                       \
    `# Updating package list`                                                                                       && \
    apt-get update                                                                                                  && \
                                                                                                                       \
    `# Add PHP7.2 Repository`                                                                                       && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php                                                            && \
                                                                                                                       \
    `# Update package list for php7.2 packages`                                                                     && \
    apt-get update                                                                                                  && \ 
                                                                                                                       \
    `# Install PHP7.2`                                                                                              && \
    apt-get install -y php7.2-fpm                                                                                      \
    php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml                    && \
                                                                                                                       \
    `# Install PHP Sql Server Support`                                                                              && \
    pecl install sqlsrv-5.2.0 pdo_sqlsrv-5.2.0                                                                      && \
                                                                                                                       \
    `# Enable SQL Server PDO Extension in PHP`                                                                      && \
    echo extension=pdo_sqlsrv.so > /etc/php/7.2/cli/conf.d/pdo_sqlsrv.ini                                           && \
    echo extension=pdo_sqlsrv.so > /etc/php/7.2/fpm/conf.d/pdo_sqlsrv.ini                                           && \
                                                                                                                       \
    `# Install SQL Server Support`                                                                                  && \
    echo extension=sqlsrv.so > /etc/php/7.2/cli/conf.d/sqlsrv.ini                                                   && \
    echo extension=sqlsrv.so > /etc/php/7.2/fpm/conf.d/sqlsrv.ini                                                   && \
                                                                                                                       \
    `# Install Composer`                                                                                            && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer                  && \
                                                                                                                       \
    `# Install Nginx and Supervisor`                                                                                && \
    apt-get update && apt-get install -y nginx supervisor                                                           && \
                                                                                                                       \
    `# Set permissions`                                                                                             && \
    chown -R www-data:www-data /var/www                                                                             && \
                                                                                                                       \
    `# Start services`                                                                                              && \
    service php7.2-fpm start                                                                                        && \
    service nginx start                                                                                             && \
    service cron start

WORKDIR /var/www/html

RUN sed -e 's/;clear_env = no/clear_env = no/' -i /etc/php/7.2/fpm/pool.d/www.conf


EXPOSE 8080

COPY nginx.conf /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisord.conf
CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]