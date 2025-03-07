# Usa Red Hat UBI 9 minimal como base
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Mantainer
MAINTAINER Jose Manuel Calvo <jcalvo@redhat.com>

# Variables de entorno
ENV DOCUMENTROOT /var/www/html/

# Metadatos para OpenShift
LABEL io.k8s.description="Imagen de servidor Apache en UBI 9" \
      io.k8s.display-name="Servidor Apache en UBI 9" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,webserver,apache,http"

# Instalar Apache y dependencias necesarias
RUN microdnf install -y httpd httpd-tools && \
    microdnf clean all && \
    sed -i 's/^Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf && \
    echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

# Crear directorios y asignar permisos adecuados
RUN mkdir -p /run/httpd /var/www/html /var/log/httpd && \
    chown -R 1001:0 /run/httpd /var/www/html /var/log/httpd && \
    chmod -R 775 /run/httpd /var/www/html /var/log/httpd

# Redirigir logs a stdout/stderr para evitar errores de permisos
RUN ln -sf /dev/stdout /var/log/httpd/access_log && \
    ln -sf /dev/stderr /var/log/httpd/error_log

# Copiar el archivo index.html
ADD files/index.html ${DOCUMENTROOT}/index.html

# Exponer el puerto 8080
EXPOSE 8080

# Usar un usuario no root (para OpenShift y Podman)
USER 1001

# Comando de inicio con logs en foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
