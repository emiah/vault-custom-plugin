#!/bin/sh

set -e

mv /vault/vault-plugin-database-oracle /vault/plugins/

# Calculate SHA256 checksum of the plugin
PLUGIN_SHASUM=$(sha256sum /vault/plugins/vault-plugin-database-oracle | cut -d ' ' -f1)

# Register the plugin with Vault using its SHA256 checksum
vault plugin register -sha256="$PLUGIN_SHASUM" database vault-plugin-database-oracle

# Add the plugin to Vault's plugin catalog
vault write sys/plugins/catalog/database/vault-plugin-database-oracle \
    sha256="$PLUGIN_SHASUM" \
    command="vault-plugin-database-oracle"
