FROM tomcat:9-jdk11
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
RUN  rm -rf /usr/local/tomcat/webapps/ROOT
EXPOSE 8080