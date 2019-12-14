FROM centos:7

MAINTAINER Jose Manuel Calvo <jcalvo@redhat.com>

ENV DOCUMENTROOT   /var/www/html/

LABEL io.k8s.description="Descripcion Imagen de servidor Apache" \
      io.k8s.display-name="Imagen de servidor Apache" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,webserver,apache,http"

RUN yum -y install -y httpd && \
    yum clean all &&  \
    sed 's/^Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf > /etc/httpd/conf/httpd.conf.new  &&  \
    cp /etc/httpd/conf/httpd.conf.new  /etc/httpd/conf/httpd.conf 

ADD files/index.html ${DOCUMENTROOT}/index.html

EXPOSE 8080

CMD  ["httpd", "-D", "FOREGROUND"]
