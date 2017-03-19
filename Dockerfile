FROM ubuntu:16.04

RUN apt update
RUN apt install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt install -y \
    git \
    curl \
    cron \
    wget \
    zsh \
    nano \
    supervisor \
    nginx \
    php5.6 \
    php5.6-fpm \
    php5.6-cli \
    php5.6-curl \
    php5.6-zip \
    php5.6-json \
    php5.6-mysql \
    php5.6-pgsql \
    php5.6-mcrypt \
    php5.6-mbstring \
    php5.6-gd \
    php5.6-xml

RUN apt autoremove -y && \
    apt clean && \
    apt autoclean

RUN apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean

RUN mkdir /run/php/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i "s/display_errors = On/display_errors = Off/" /etc/php/5.6/fpm/php.ini
RUN sed -i "s/user = www-data/user = root/" /etc/php/5.6/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php/5.6/fpm/pool.d/www.conf

# Supervisor conf
RUN echo "[supervisord]" >> /etc/supervisor/supervisord.conf
RUN echo "nodaemon = true" >> /etc/supervisor/supervisord.conf
RUN echo "user = root" >> /etc/supervisor/supervisord.conf

RUN echo "[program:php-fpm5.6]" >> /etc/supervisor/supervisord.conf
RUN echo "command = /usr/sbin/php-fpm5.6 -FR" >> /etc/supervisor/supervisord.conf
RUN echo "autostart = true" >> /etc/supervisor/supervisord.conf
RUN echo "autorestart = true" >> /etc/supervisor/supervisord.conf

RUN echo "[program:nginx]" >> /etc/supervisor/supervisord.conf
RUN echo "command = /usr/sbin/nginx" >> /etc/supervisor/supervisord.conf
RUN echo "autostart = true" >> /etc/supervisor/supervisord.conf
RUN echo "autorestart = true" >> /etc/supervisor/supervisord.conf

RUN echo "[program:cron]" >> /etc/supervisor/supervisord.conf
RUN echo "command = cron -f" >> /etc/supervisor/supervisord.conf
RUN echo "autostart = true" >> /etc/supervisor/supervisord.conf
RUN echo "autorestart = true" >> /etc/supervisor/supervisord.conf


# Install Zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
RUN sed -i "s/robbyrussell/af-magic/" ~/.zshrc
RUN echo TERM=xterm >> /root/.zshrc

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add certbot
# https://certbot.eff.org/
RUN wget -P /usr/sbin/ https://dl.eff.org/certbot-auto
RUN chmod a+x /usr/sbin/certbot-auto

RUN chown -R root:root /etc/cron.d
RUN chmod -R 0644 /etc/cron.d

CMD ["/usr/bin/supervisord"]
