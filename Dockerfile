FROM ubuntu:latest
LABEL authors="wellyson"

# Etapa de construção
FROM maven:3.9.0-eclipse-temurin-17 AS builder

WORKDIR /app

# Copia o pom.xml e o código-fonte
COPY pom.xml /app
COPY src /app/src

# Expor a porta
EXPOSE 8762

# Executa o comando Maven para empacotar o JAR
RUN mvn clean install -DskipTests

# Etapa de execução
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copia o JAR gerado da etapa de construção
COPY --from=builder /app/target/gateway-0.0.1-SNAPSHOT.jar /app/gateway.jar

# Define o comando de execução
ENTRYPOINT ["java", "-jar", "gateway.jar"]
