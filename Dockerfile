# Use an OpenJDK base image
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy JAR file from Jenkins workspace
COPY artifacts/myapp.jar myapp.jar

# Expose the application port
EXPOSE 8080

# Run the JAR file
CMD ["java", "-jar", "myapp.jar"]
