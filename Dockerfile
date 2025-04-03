FROM openjdk:11-jdk-slim

EXPOSE 8080

ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

# Install wget
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Fetch the latest JAR version dynamically
RUN JAR_URL=$(wget -qO- "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/maven-metadata.xml" \
    | grep -oP '(?<=<value>).*?(?=</value>)' | tail -1) && \
    wget -O app.jar "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/$JAR_URL.jar"

CMD ["java", "-jar", "app.jar"]
