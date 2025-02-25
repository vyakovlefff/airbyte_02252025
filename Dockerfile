# Use OpenJDK as the base image since Airbyte requires Java
FROM openjdk:17-jdk-slim AS builder

# Set environment variables
ENV AIRBYTE_VERSION=0.50.21 \
    AIRBYTE_HOME=/app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
WORKDIR $AIRBYTE_HOME
RUN git clone --depth 1 --branch v$AIRBYTE_VERSION https://github.com/airbytehq/airbyte.git .

# Build Airbyte
WORKDIR $AIRBYTE_HOME
RUN ./gradlew build -x test

# Create runtime image
FROM openjdk:17-jdk-slim AS runtime

# Set environment variables
ENV AIRBYTE_HOME=/app
WORKDIR $AIRBYTE_HOME

# Copy built files
COPY --from=builder /app /app

# Expose necessary ports
EXPOSE 8000 8001 8002

# Start Airbyte server
CMD ["./run-ab-platform.sh"]
