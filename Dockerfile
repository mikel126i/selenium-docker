FROM openjdk:8u191-jre-alpine3.8

RUN apk add curl jq


#Workspace
WORKDIR /usr/share/udemy

# ADD .jar under target from host
# los archivos se pegaran en en WORKDIR del contenedor
ADD target/selenium-docker.jar selenium-docker.jar
ADD target/selenium-docker-tests.jar selenium-docker-tests.jar
ADD target/libs libs

# in case of any other dependency like .csv /.json, etc, ADD as well
# ADD suite files
ADD book-flight-module.xml book-flight-module.xml
ADD search-module.xml search-module.xml

#BROWSER
#HUB_HOST
#MODULE

#instrucciones de ejecucion del test (si al levantar el contenedor sobrescribo el entrypoint con --entrypoint=/bin/sh, no se ejecutan los tests)
# no me queda muy claro como escoge los valores por defecto. El unico valor obligatorio es $MODULE (creo que coge los valores del codigo de java)
#Ahora el codigo del entrypoint (java -c) se ejecuta en el healthcheck.sh
#ENTRYPOINT java -cp selenium-docker.jar:selenium-docker-tests.jar:libs/* -DBROWSER=$BROWSER -DHUB_HOST=$HUB_HOST org.testng.TestNG $MODULE
# java -cp selenium-docker.jar:selenium-docker-tests.jar:libs/* -DHUB_HOST=192.168.1.92 org.testng.TestNG book-flight-module.xml
# docker run -ti --entrypoint=/bin/sh -v C:\Users\Usuario\IdeaProjects\test\output:/usr/share/udemy/test-output mikel126/selenium-docker

ADD healthcheck.sh healthcheck.sh
#ejecutamos comando para convertir formato windows a formato unix
RUN dos2unix healthcheck.sh
ENTRYPOINT sh healthcheck.sh

###################################pasos
##########levantamos el selenium grid con docker-compose
#docker-compose up
##########construimos imagen a partir de este dockerfile
#docker build -t mikel126/selenium-docker . 
##########levantamos el contenedor (al no sobrescribir el entrypoint, también ejecutamos el test)
#docker run -v C:\Users\Usuario\IdeaProjects\test\output:/usr/share/udemy/test-output -e HUB_HOST=192.168.1.92 -e MODULE=book-flight-module.xml mikel126/selenium-docker

###############################alternativa
# una vez construida la imagen con docker build, podemos correrla directamente desde el docker-compose up mediante el siguiente servicio:
#  search-module:
#    image: mikel126/selenium-docker
#    depends_on:
#      - chrome
#      - firefox
#    environment:
#      - MODULE=book-flight-module.xml
#      #- HUB_HOST=192.168.1.92
#      - HUB_HOST=hub
#    volumes:
#      - ./search-result:/usr/share/udemy/test-output

