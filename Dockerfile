# syntax=docker/dockerfile:1.4

# Build arguments
ARG BUILD_DATE
ARG VERSION
ARG REVISION

# Build stage
FROM maven:3.8.6-eclipse-temurin-11 AS builder

# Clone and build the AT-Emulator
RUN git clone https://github.com/celersms/AT-Emulator.git /src
WORKDIR /src
RUN mkdir -p target/classes/com/celer/emul
RUN javac -d target/classes src/com/celer/emul/AT.java

# Final stage
FROM eclipse-temurin:11-jre

# Add labels
LABEL \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.authors="Oleksii Dmytryk <@ioleksiy>" \
    org.opencontainers.image.url="https://github.com/ioleksiy/docker-at-emulator" \
    org.opencontainers.image.documentation="https://github.com/ioleksiy/docker-at-emulator#readme" \
    org.opencontainers.image.source="https://github.com/ioleksiy/docker-at-emulator" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.revision="${REVISION}" \
    org.opencontainers.image.vendor="Oleksii Dmytryk" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="AT-Emulator" \
    org.opencontainers.image.description="Docker image for AT-Emulator - A virtual AT command emulator"

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    socat && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled classes
COPY --from=builder /src/target/classes /app/classes

# Set working directory
WORKDIR /app

# Default configuration
ENV PORT=8000
ENV WORKERS=4
ENV MAX_CONNECTIONS=10

# Expose the default port
EXPOSE ${PORT}

# Create a simple startup script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'socat -d -d pty,link=/dev/ttyS0,raw,echo=0,waitslave tcp-listen:${PORT},fork,reuseaddr &' >> /entrypoint.sh && \
    echo 'exec java -cp /app/classes com.celer.emul.AT ${PORT} ${WORKERS} ${MAX_CONNECTIONS}' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
