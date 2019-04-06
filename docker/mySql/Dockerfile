FROM mysql:5.7

COPY waitForMySQL.sh /root/
RUN chmod +x /root/waitForMySQL.sh

RUN cp -r /var/lib/mysql /var/lib/mysql-no-volume

CMD ["--datadir", "/var/lib/mysql-no-volume"]