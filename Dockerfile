# Use a base image with necessary build tools
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    nasm \
    gdb \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files and configuration
COPY src/ ./src/
COPY public/ ./public/
COPY script.sh ./
COPY server.conf ./

# Create log directory
RUN mkdir -p log

# Make script executable
RUN chmod +x script.sh

# Build the server
RUN ./script.sh compile

# Expose the configured port (from server.conf)
EXPOSE 8081

# Set healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8081/ || exit 1

# Run the server
CMD ["./asm_server"]
