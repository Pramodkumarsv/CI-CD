FROM openjdk:11-jdk-slim

EXPOSE 8080

ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

# Install necessary tools (curl, wget, grep, xmllint)
RUN apt-get update && apt-get install -y wget curl libxml2-utils && rm -rf /var/lib/apt/lists/*

# Fetch latest JAR dynamically
RUN JAR_URL=$(curl -s "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/maven-metadata.xml" \
   | grep -oP '(?<=<extension>jar</extension>\s*<value>).*?(?=</value>)' | tail -1) && \
   echo "Downloading: http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/$JAR_URL.jar" && \
   wget -O app.jar "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/$JAR_URL.jar"

CMD ["java", "-jar", "app.jar"]
