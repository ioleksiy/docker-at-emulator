# Build stage
FROM maven:3.8.6-eclipse-temurin-11 AS builder

# Clone and build the AT-Emulator
RUN git clone https://github.com/celersms/AT-Emulator.git /src
WORKDIR /src
RUN mkdir -p target/classes/com/celer/emul
RUN javac -d target/classes src/com/celer/emul/AT.java

# Final stage
FROM eclipse-temurin:11-jre

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
