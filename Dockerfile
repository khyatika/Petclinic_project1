FROM jetty:11-jdk17
COPY target/petclinic.war /usr/local/jetty/webapps/ROOT.war
EXPOSE 8080
