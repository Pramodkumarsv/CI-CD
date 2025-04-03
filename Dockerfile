FROM openjdk:17-jdk-slim

WORKDIR /app

# Install necessary tools
RUN apt-get update && apt-get install -y wget curl libxml2-utils

# Fetch latest JAR dynamically
RUN JAR_URL=$(curl -s "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/maven-metadata.xml" \
    | xmllint --xpath "string(//metadata/versioning/snapshotVersions/snapshotVersion[extension='jar']/value)" -) && \
    echo "Downloading: http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/${JAR_URL}.jar" && \
    wget -O app.jar "http://10.20.42.99:8081/repository/maven-releases/First_project/Maven_First_Project_Demo/0.0.1-SNAPSHOT/${JAR_URL}.jar"

# Run the application
CMD ["java", "-jar", "app.jar"]
