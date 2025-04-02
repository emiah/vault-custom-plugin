FROM ubuntu:22.04

ARG VAULT_VERSION=1.16.3
ARG DATABASE_ORACLE_PLUGIN_VERSION=0.10.2
ARG ARCH=amd64

# Install system dependencies and clean up
RUN apt update && apt -y upgrade \
    && apt install -y gnupg wget unzip dumb-init libcap2-bin libaio1 gosu \
    && rm -rf /var/lib/apt/lists/*

# Create vault user and group with consistent IDs
RUN useradd -ms /bin/bash vault

# Create directory structure for Vault
# /vault/logs - for audit logs
# /vault/file - for file storage backend
# /vault/config - for configuration files
# /vault/plugins - for file pluginss
RUN mkdir -p /vault/logs && \
    mkdir -p /vault/file && \
    mkdir -p /vault/config && \
    mkdir -p /vault/plugins

# Download and install Vault and Oracle plugin
RUN mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${ARCH}.zip && \
    unzip -d /bin vault_${VAULT_VERSION}_linux_${ARCH}.zip && \
    wget https://releases.hashicorp.com/vault-plugin-database-oracle/${DATABASE_ORACLE_PLUGIN_VERSION}/vault-plugin-database-oracle_${DATABASE_ORACLE_PLUGIN_VERSION}_linux_${ARCH}.zip && \
    unzip -d /vault vault-plugin-database-oracle_${DATABASE_ORACLE_PLUGIN_VERSION}_linux_${ARCH}.zip && \
    rm -rf /tmp/build

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget https://download.oracle.com/otn_software/linux/instantclient/191000/instantclient-basiclite-linux.x64-19.10.0.0.0dbru.zip && \
    unzip instantclient-basiclite-linux.x64-19.10.0.0.0dbru.zip && \
    rm instantclient-basiclite-linux.x64-19.10.0.0.0dbru.zip && \
    echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# Set Oracle environment variables
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_10:$LD_LIBRARY_PATH
ENV ORACLE_HOME=/opt/oracle/instantclient_19_10

# Copy and make executable the plugin registration script
COPY ./register-plugin.sh /vault/
RUN chmod +x /vault/register-plugin.sh

# Set ownership for vault directories
RUN chown -R vault:vault /vault

# Expose volumes for persistent data
VOLUME /vault/logs  # For audit logs
VOLUME /vault/file  # For file storage backend
VOLUME /vault/plugins  # For file plugins

# Expose the primary Vault port
EXPOSE 8200

# Copy entrypoint script and make executable
COPY ./docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh

# Use dumb-init as entrypoint to properly handle signals
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command: start a single-node development server
# Note: This configuration is not suitable for production
CMD ["server", "-dev"]
