# Vault with Oracle Database Plugin Docker Image

This repository contains a Dockerfile to build a custom HashiCorp Vault image with the [vault-plugin-database-oracle](https://github.com/hashicorp/vault-plugin-database-oracle) plugin pre-installed, running on Ubuntu.

## Overview

This Docker image provides a Vault server with the official Oracle Database plugin, enabling Vault to:
- Generate dynamic credentials for Oracle databases
- Manage Oracle database users with lease-based lifecycle
- Rotate root credentials for Oracle databases

## Features

- HashiCorp Vault with Oracle Database plugin pre-installed
- Ubuntu-based image for stability
- Proper plugin directory structure and permissions
- Ready-to-use configuration for the Oracle plugin

## Usage

### Quick Start

```bash
docker compose up --build -d
