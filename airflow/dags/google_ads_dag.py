from airflow import DAG
from airflow.providers.google.ads.hooks.ads import GoogleAdsHook
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import logging

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'google_ads_dag',
    default_args=default_args,
    description='DAG for fetching Google Ads data',
    schedule_interval=timedelta(days=1),
)

def fetch_google_ads_data():
    hook = GoogleAdsHook(google_ads_conn_id='google_ads_conn_id')
    client = hook.get_client()
    
    try:
        with open('dbt/models/staging/google_ads.sql', 'r') as file:
            query = file.read()
        
        response = client.get_service("GoogleAdsService").search_stream(
            customer_id="556-558-5472", query=query
        )
        
        for batch in response:
            for row in batch.results:
                campaign = row.campaign
                metrics = row.metrics
                
                logging.info(f"Campaign ID: {campaign.id}, Name: {campaign.name}")
                logging.info(f"Clicks: {metrics.clicks}, Impressions: {metrics.impressions}, Conversions: {metrics.conversions}")
                
    except Exception as e:
        logging.error(f"Error fetching Google Ads data: {e}")

fetch_google_ads_task = PythonOperator(
    task_id='fetch_google_ads_task',
    python_callable=fetch_google_ads_data,
    dag=dag,
)