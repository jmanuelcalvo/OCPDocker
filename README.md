# Buenas practicas de despliegue de contenedores de Docker en OpenShift

Dentro de las estrategias de migracion a OpenShift, muchos empresas cuentan con sus aplicaciones actualmente en fabricas de contenedores con Docker.

Teniendo en cuenta que OpenShift permite ejecutar dichos contenedores los pasos para la ejecucion son:

1. Identificar la url del registry de Docker
2. Garantizar que la imagen del contenedor:
* Al momento de su ejecucion llame al comando CMD el cual garantiza cual va a ser el proceso de inicio del servicio, en caso que este parametro no se encuentre seteado, este va a fallar al momento del deploy dentro de OpenShift
* El puerto de exposicion de la imagen sea mayor a 1024, ya que de lo contrario requiere privilegios de ejecucion el en cluster de OpenShift

```
EXPOSE 8080

CMD  ["httpd", "-D", "FOREGROUND"]

o 

CMD bash -c "while true; do echo test; sleep 5; done"
```

3. Relizar las pruebas de ejeucion en su docker local
```
[root@bastion ~]# sudo docker run -d -p 8080:8080 --name=apache01 jmanuelcalvo/apache
[root@bastion ~]# docker ps
CONTAINER ID        IMAGE                 COMMAND                 CREATED             STATUS              PORTS                            NAMES
72a4774ef0e9        jmanuelcalvo/apache   "httpd -D FOREGROUND"   21 seconds ago      Up 20 seconds       80/tcp, 0.0.0.0:8080->8080/tcp   apache01

[root@bastion ~]# docker exec -it apache01 bash
[root@72a4774ef0e9 /]# ps xa
  PID TTY      STAT   TIME COMMAND
    1 ?        Ss     0:00 httpd -D FOREGROUND
    7 ?        S      0:00 httpd -D FOREGROUND
    8 ?        S      0:00 httpd -D FOREGROUND
    9 ?        S      0:00 httpd -D FOREGROUND
   10 ?        S      0:00 httpd -D FOREGROUND
   11 ?        S      0:00 httpd -D FOREGROUND
   12 ?        Ss     0:00 bash
   27 ?        R+     0:00 ps xa
[root@72a4774ef0e9 /]# exit
[root@bastion ~]# docker stop apache01
apache01
[root@bastion ~]# docker rm apache01
apache01
```

4. Crear una aplicacion en OpenShift a partir de esta imagen de contenedor
```
[root@bastion ~]# oc new-project apache01
Now using project "apache01" on server "https://loadbalancer.2775.internal:443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app centos/ruby-25-centos7~https://github.com/sclorg/ruby-ex.git

to build a new example application in Ruby.

[root@bastion ~]# oc adm policy add-scc-to-user anyuid -z default

[root@bastion ~]# oc new-app --name so --insecure-registry --docker-image="jmanuelcalvo/apache:latest"
--> Found Docker image 9a4c293 (29 hours old) from Docker Hub for "jmanuelcalvo/apache:latest"

    * An image stream tag will be created as "so:latest" that will track this image
    * This image will be deployed in deployment config "so"
    * Port 80/tcp will be load balanced by service "so"
      * Other containers can access this service through the hostname "so"
    * WARNING: Image "jmanuelcalvo/apache:latest" runs as the 'root' user which may not be permitted by your cluster administrator

--> Creating resources ...
    imagestream.image.openshift.io "so" created
    deploymentconfig.apps.openshift.io "so" created
    service "so" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/so'
    Run 'oc status' to view your app.

root@bastion ~]# oc get pod
NAME         READY     STATUS    RESTARTS   AGE
so-1-w8nbb   1/1       Running   0          4m
```

