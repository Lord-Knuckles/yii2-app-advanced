FROM yiisoftware/yii2-php:7.2-apache

# Change document root for Apache
RUN sed -i -e 's|/app/web|/app/frontend/web|g' /etc/apache2/sites-available/000-default.conf

# install mysql driver
RUN docker-php-ext-install pdo pdo_mysql

# ARG USER_ID=1000
# ARG GROUP_ID=1000

# RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
#     userdel -f www-data &&\
#     if getent group www-data ; then groupdel www-data; fi &&\
#     groupadd -g ${GROUP_ID} www-data &&\
#     useradd -l -u ${USER_ID} -g www-data www-data &&\
#     install -d -m 0755 -o www-data -g www-data /home/www-data &&\
#     chown --changes --silent --no-dereference --recursive \
#           --from=33:33 ${USER_ID}:${GROUP_ID} \
#         /app \       
# ;fi
        
# USER www-data
USER 1000 