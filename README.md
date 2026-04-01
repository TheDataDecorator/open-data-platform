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


## 🚀 Getting Started: Data Ingestion

Once you have run `docker compose up -d`, you can access your platform at `http://localhost`. Follow these steps to initialize your data pipeline.

### 1. Uploading Data Files via the Dashboard
The main interface includes a **Data Ingestion** card. This is the primary way to send raw data into the system for processing.

* **Access:** Navigate to `http://localhost` in your browser.
* **Action:** Click **"Select File"** or drag-and-drop your CSV/JSON file into the upload zone.
* **Process:** The system automatically moves the file to the secure NiFi `inbox`. From there, the automated pipeline will pick it up, transform it, and load it into your **PostgreSQL Data Warehouse**.
* **Confirmation:** You will see a success message on the dashboard once the file is safely handed off to the processing engine.

### 2. Importing the NiFi Process Group
If your NiFi canvas is empty on first launch, you can import the pre-defined logic using the **Process Group** tool.

1.  **Open NiFi:** Navigate to your NiFi instance (typically `https://localhost:8443/nifi`).
2.  **Locate the Tool:** On the top navigation bar, find the **Process Group** icon (the square folder icon).
3.  **Deploy to Canvas:** Click and drag that icon onto the center of the empty graph paper.
4.  **Import Definition:** * In the "Add Process Group" window, **do not** type a name. 
    * Click the **Import** link located in the bottom-left of the window.
    * Select the `flow.json` file from the `/nifi_setup` folder in this repository.
5.  **Initialize:** * Once the group appears, double-click to enter it.
    * Right-click the canvas and select **"Enable All Controller Services"**.
    * Right-click again and select **"Start"** to begin processing data.

### 3. Verifying the Data in PostgreSQL
To confirm your data has been successfully processed and stored, you can use the integrated **pgAdmin** tool or a SQL query.

1.  **Open pgAdmin:** Navigate to `http://localhost:5050`.
2.  **Connect:** Expand the **Servers** group and select **Data Warehouse**.
3.  **Query the Table:** * Right-click your target database (e.g., `warehouse`) and select **Query Tool**.
    * Run the following command to see your recently ingested rows:
      ```sql
      SELECT * FROM your_table_name ORDER BY created_at DESC LIMIT 10;
      ```
4.  **Success:** If you see your uploaded CSV data in the results grid, your pipeline is fully operational.

### 📝 Maintenance
- **Adding Drivers**: Drop .jar files into ./nifi/drivers to make them available to NiFi processors
- **DB Init**: Custom SQL in ./init-db.sql will run automatically on the first initialization of the Postgres container
- **Logs**: pgAdmin logs are persisted to a named volume for persistent troubleshooting

## ⚙️ Data Pipeline Architecture

The Apache NiFi service manages the automated Extract, Transform, and Load (ETL) operations for the platform. The flow is designed for high-availability processing and follows a standardized four-stage lifecycle:

### 1. Automated Ingestion
The pipeline monitors the designated ingestion directory (`/opt/nifi/nifi-current/inbox`) in real-time. Upon detection of a new file, the system:
* Synchronizes the file into a NiFi FlowFile.
* Removes the source file from the landing zone to prevent redundant processing.
* Assigns unique UUIDs to every data packet for end-to-end tracking.

### 2. Validation and Schema Enforcement
To maintain data integrity, the flow performs the following checks:
* **Format Identification:** Distinguishes between CSV, JSON, and other supported formats.
* **Schema Matching:** Validates that incoming fields align with the predefined database structure.
* **Routing:** Successfully validated files proceed to transformation, while malformed data is isolated in a `failure/` repository for manual review.

### 3. Transformation and Enrichment
Before the data is committed to the warehouse, it undergoes standardized processing:
* **Data Normalization:** Adjusts data types (e.g., converting strings to ISO-8601 timestamps).
* **Metadata Attachment:** Appends administrative fields such as `ingestion_source` and `load_timestamp`.
* **Field Mapping:** Maps source attributes to the target PostgreSQL table schema.

### 4. Database Integration
The final stage handles the secure transfer of data to the PostgreSQL Data Warehouse:
* **Connection Management:** Utilizes a DBCP (Database Connection Pool) for optimized performance and resource management.
* **Data Insertion:** Records are appended to the target tables in the PostgreSQL environment, ensuring all incoming data points are captured for downstream analysis.

### 5. Audit and Provenance
Every transaction within the pipeline is indexed. Users can access the **Data Provenance** feature within the NiFi UI to view a complete lineage of any data point, providing a transparent audit trail from the initial upload to the final database commit.