FROM tomcat:latest

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the webapp content into the Tomcat webapps directory
COPY SampleWebApp/src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

# Expose port 8080 (the default Tomcat port)
EXPOSE 8080
