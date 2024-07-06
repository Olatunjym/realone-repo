FROM tomcat:latest

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the .war file into the Tomcat webapps directory
COPY target/SampleWebApp.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 (the default Tomcat port)
EXPOSE 8080
