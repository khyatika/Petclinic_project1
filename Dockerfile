FROM jetty:11-jdk17
ENV WAR_FILE petclinic.war
COPY target/${WAR_FILE} /usr/local/jetty/webapps/${WAR_FILE}
EXPOSE 8080