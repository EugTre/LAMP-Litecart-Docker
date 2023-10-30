FROM ubuntu:latest

# Install deps
RUN apt update && \
    apt -y upgrade && \
    apt -y install language-pack-en && \
    apt -y install curl unzip nano && \
    DEBIAN_FRONTEND=NONINTERACTIVE apt -y install apache2 tzdata && \
    apt -y install libapache2-mod-php mysql-server php php-common php-cli php-fpm php-apcu php-curl php-dom php-gd php-imagick php-mysql php-simplexml php-mbstring php-intl php-zip php-xml

WORKDIR /home
COPY . .

# Setup DB
RUN service mysql stop && \
    usermod -d /var/lib/mysql/ mysql && \
    service mysql start && \
    mysql -uroot < /home/db_setup

# Setup Apache2
RUN sed -ri 's/memory_limit = 128M/memory_limit = 265M/' /etc/php/8.1/apache2/php.ini && \
    sed -ri 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/8.1/apache2/php.ini && \
    sed -ri 's/;date.timezone =/date.timezone = Europe\/Moscow/' /etc/php/8.1/apache2/php.ini && \
    mv /home/sites_setup /etc/apache2/sites-enabled/000-default.conf && \
    a2enmod rewrite headers proxy_fcgi setenvif

# Prepare for installation
WORKDIR /var/www/html
RUN rm index.html && \
    curl -so litecart.zip "https://www.litecart.net/en/downloading?action=get&version=latest" && \
    unzip litecart.zip "public_html/*" && \
    mv -f public_html/* ./ && \
    rm -rf public_html/ && \
    rm -f litecart.zip && \
    chown -R www-data:www-data ./

# Install
WORKDIR install
RUN service apache2 restart && \
    service mysql restart && \
    php install.php \
  --document_root="/var/www/html" \
  --db_server="127.0.0.1" \
  --db_database=litecart \
  --db_username=admin \
  --db_password=secret \
  --db_prefix="lc_" \
  --db_collation="utf8mb4_0900_ai_ci" \
  --country="RU" \
  --timezone="Europe/Moscow" \
  --admin_folder=admin \
  --username=admin \
  --password=secret \
  --development_type=standard \
  --cleanup

# Cleanup
WORKDIR /var/www/html
RUN rm -rf install

EXPOSE 80

ENTRYPOINT service apache2 start && mysqld_safe
