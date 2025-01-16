# Usando uma imagem base do OpenJDK 17
FROM ubuntu:latest
LABEL authors="wellyson"

# Etapa de construção
FROM maven:3.9.0-eclipse-temurin-17 AS builder

WORKDIR /app

# Copiar o pom.xml e o código-fonte
COPY pom.xml /app
COPY src /app/src

# Executa o comando Maven para empacotar o JAR
RUN mvn clean install -DskipTests

# Etapa de execução
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Expondo a porta para a aplicação
EXPOSE 8762

# Instalar bash (caso não esteja instalado)
RUN apk add --no-cache bash

# Copiar o JAR gerado da etapa de construção
COPY --from=builder /app/target/gateway-0.0.1-SNAPSHOT.jar /app/gateway.jar

# Copiar o script wait-for-it.sh do server-lsim para dentro do pagamentos-lsim
COPY --from=server-lsim /app/wait-for-it.sh /app/wait-for-it.sh

# Tornar o script executável
RUN chmod +x /app/wait-for-it.sh

# Definir o comando de execução para aguardar o Eureka Server e então iniciar a aplicação
ENTRYPOINT ["/app/wait-for-it.sh", "server-lsim", "8761", "--", "java", "-jar", "gateway.jar"]
