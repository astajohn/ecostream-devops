FROM amazonlinux:2

RUN yum update -y && \
    yum install -y httpd

COPY app/ /var/www/html/

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
