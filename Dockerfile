FROM l3iggs/lamp
MAINTAINER l3iggs <l3iggs@live.com>
# Report issues here: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/

# remove info.php
RUN sudo rm /srv/http/info.php

# install some owncloud optional deps
RUN sudo pacman -S --noconfirm --needed smbclient ffmpeg
# libreoffice-common no longer exists
#RUN pacman -Suy --noconfirm --needed  libreoffice-common

# Install owncloud
RUN sudo pacman -S --noconfirm --needed owncloud

# Install owncloud addons
RUN sudo pacman -S --noconfirm --needed owncloud-app-bookmarks owncloud-app-calendar owncloud-app-contacts owncloud-app-documents

# enable large file uploads
RUN sudo sed -i 's,php_value upload_max_filesize 513M,php_value upload_max_filesize 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sudo sed -i 's,php_value post_max_size 513M,php_value post_max_size 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sudo sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php5.c>\nphp_value output_buffering Off,g' /usr/share/webapps/owncloud/.htaccess

# setup Apache for owncloud
ADD owncloud.conf /etc/httpd/conf/extra/owncloud.conf
RUN sudo sed -i 's,Options Indexes FollowSymLinks,Options -Indexes,g' /etc/httpd/conf/httpd.conf
RUN sudo sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf
RUN sudo chown -R http:http /usr/share/webapps/owncloud/

EXPOSE 80 80
EXPOSE 443 443

VOLUME /usr/share/webapps/owncloud/data /etc/webapps/owncloud/config

# start apache and mysql
CMD cd '/usr'; sudo /usr/bin/mysqld_safe --datadir='/var/lib/mysql'& sudo apachectl -DFOREGROUND
