FROM openjdk:11-jdk-slim

EXPOSE 8080

ENV APP_HOME /usr/src/app

# Create application directory
WORKDIR $APP_HOME

# Download the latest JAR dynamically
RUN apt-get update && apt-get install -y wget && \
    wget -O app.jar "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/$(wget -qO- http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/maven-metadata.xml | grep -oP '(?<=<value>).*?(?=</value>)' | tail -1).jar"

# Run the application
CMD ["java", "-jar", "app.jar"]
