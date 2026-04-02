from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
import os

# One-Touch: We pull the password from the environment so it's never in the code
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'csv_data_transform',
    default_args=default_args,
    description='Triggers dbt to transform raw csv data to Silver layer',
    schedule_interval=None, # Triggered manually or via NiFi API
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['dbt', 'postgres'],
) as dag:

    # Task 1: Check dbt connection (Debug step)
    debug_dbt = BashOperator(
        task_id='debug_dbt_connection',
        bash_command='cd /opt/airflow/dbt && dbt debug --profiles-dir . || true',
        env={'POSTGRES_PASSWORD': POSTGRES_PASSWORD},
        append_env=True
    )

    # Task 2: Run Transformations (Bronze -> Silver)
    run_dbt = BashOperator(
        task_id='run_dbt_transformations',
        bash_command='cd /opt/airflow/dbt && dbt run --profiles-dir .',
        env={'POSTGRES_PASSWORD': POSTGRES_PASSWORD},
        append_env=True
    )

    debug_dbt >> run_dbt