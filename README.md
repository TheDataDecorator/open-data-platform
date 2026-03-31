# 🚀 DataOps-in-a-Box: Modern Data Stack

An automated, containerized data engineering ecosystem. This platform orchestrates the entire data lifecycle—from ingestion and transformation to visualization and real-time health monitoring.

---

## 🏗️ Architecture Overview

This project leverages Docker Compose to manage a professional-grade multi-layered stack:

- 📥 **Ingestion**: Apache NiFi 2.x for automated, visual data flows  
- 💾 **Storage**: PostgreSQL 15 serving as the central Data Warehouse  
- ⚙️ **Orchestration**: Apache Airflow for complex DAG management  
- 🛠️ **Transformation**: dbt (data build tool) for SQL modeling and automated documentation  
- 📊 **Visualization**: Apache Superset for enterprise BI dashboards  
- 🔧 **Management**: pgAdmin 4 for DB administration and an automated Backup Service  
- 🚦 **Monitoring**: Custom Docker Status API with a centralized Nginx reverse proxy  

---

## 🚦 Quick Start

### 1. Prerequisites

- Docker & Docker Compose installed  
- A `.env` file located in the parent directory (see `.env.example`)  

### 2. Launch the Stack

```bash
docker-compose up -d
```

### 3. Service Map

Once the stack is healthy, access the interfaces via these ports:

| Service     | Port | Description                                  |
|------------|------|----------------------------------------------|
| Gateway     | 80   | Main Nginx Entrypoint / Dashboard            |
| Airflow     | 8080 | Workflow & DAG Management                    |
| Superset    | 8088 | BI & Data Visualization                      |
| NiFi        | 8443 | Data Ingestion (HTTPS)                       |
| pgAdmin     | 5050 | Database GUI                                 |
| dbt Docs    | 8082 | Data Lineage & Schema Documentation          |
| Status API  | 9000 | Real-time Container Monitoring               |

---

## 🛠️ Key Features

### 🔄 Intelligent Orchestration

- **Self-Healing**: Services use Docker healthchecks to ensure the Postgres Warehouse is ready before Airflow or Superset attempt to boot  
- **Auto-Provisioning**: Airflow automatically migrates the DB and creates an Admin user on startup using environment variables  

### 📖 Living Documentation

- **dbt-docs-gen**: A dedicated background service that runs `dbt docs generate` every hour  
- **Static Serving**: An Nginx container (`dbt-docs`) serves the generated documentation at port 8082 for easy team access  

### 🛡️ Reliability & Security

- **Automated Backups**: A dedicated backup service runs a `pg_dump` every 24 hours to the `/backups` volume  
- **Reverse Proxy**: Nginx handles traffic routing and is pre-configured for SSL via volume-mounted certs  
- **NiFi 2.x Ready**: Configured for the latest security standards, including mandatory 12-character credentials  

### 📈 Health Monitoring

A custom Docker Status API (Python 3.12 / Flask) communicates directly with the Docker socket to provide real-time **"Up/Down"** statuses for all containers in the deployment, exposed via a clean JSON API.

---

## 📁 Project Structure

```plaintext
├── airflow/            # DAGs and Airflow configuration
├── dbt/                # dbt models, profiles, and analytics
├── nginx/              # nginx.conf and SSL certificates
├── nifi/               # JDBC drivers and flow configurations
├── superset/           # Bootstrapping scripts and custom configs
├── www/                # Frontend assets for the status dashboard
└── docker-compose.yml  # System orchestration
```


### 📝 Maintenance
- **Adding Drivers**: Drop .jar files into ./nifi/drivers to make them available to NiFi processors
- **ADB Init**: Custom SQL in ./init-db.sql will run automatically on the first initialization of the Postgres container
- **ALogs**: pgAdmin logs are persisted to a named volume for persistent troubleshooting