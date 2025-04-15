FROM jetty:11-jdk17
ENV WAR_FILE petclinic.war
COPY target/${WAR_FILE} /usr/local/jetty/webapps/ROOT.war
EXPOSE 8080
