FROM openjdk:17-jdk-slim

# JAR 파일 복사
COPY ./build/libs/k8s_prac01-0.0.1-SNAPSHOT.jar /app.jar

EXPOSE 80

ENTRYPOINT ["java", "-jar", "/app.jar"]
