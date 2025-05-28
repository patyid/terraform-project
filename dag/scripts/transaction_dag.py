import os
from datetime import datetime
import pendulum
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.providers.amazon.aws.sensors.emr_step import EmrStepSensor
from airflow.providers.amazon.aws.operators.emr_terminate_job_flow import EmrTerminateJobFlowOperator

from dag.utils.emrUtils import EmrCreateCustomJobFlowOperator, EmrAddStepsCustomOperator

# Configurações básicas
dag_id = "transaction"
env = os.environ.get('AIRFLOW__CUSTOM__ENVIRONMENT', 'dev')
LOCAL_TZ = pendulum.timezone("America/Sao_Paulo")
START_DATE = datetime(2024, 1, 1).astimezone(LOCAL_TZ)

default_args = {
    'owner': 'airflow',
    'start_date': START_DATE,
    'depends_on_past': False,
    'retries': 0
}

with DAG(
    dag_id=dag_id,
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=["transaction"]
) as dag:

    inicio = DummyOperator(task_id='inicio')

    # 1. Criar cluster EMR
    criar_cluster = EmrCreateCustomJobFlowOperator(
        task_id='criar_cluster_emr',
        job_path_config='dag/cluster/cluster_transaction_{{ dag_run.conf["cluster_size"] }}.yaml',
        aws_conn_id='aws_default',
        identifier=' ({{ dag_run.conf["param_0"] }} {{ dag_run.conf["param_1"] }})'
    )

    # 2. Adicionar step PySpark
    adicionar_step = EmrAddStepsCustomOperator(
        task_id='adicionar_step_pyspark',
        job_flow_id="{{ task_instance.xcom_pull(task_ids='criar_cluster_emr') }}",
        steps_path_config='dag/step/step_cip_htrc_cdto_batch_rules.yaml',
        custom_parameters='{{ dag_run.conf["param_0"] }},{{ dag_run.conf["param_1"] }}',
        aws_conn_id='aws_default',
        identifier=' ({{ dag_run.conf["param_0"] }} {{ dag_run.conf["param_1"] }})'
    )

    # 3. Aguardar execução do step
    monitorar_step = EmrStepSensor(
        task_id='monitorar_step',
        job_flow_id="{{ task_instance.xcom_pull(task_ids='criar_cluster_emr') }}",
        step_id="{{ task_instance.xcom_pull(task_ids='adicionar_step_pyspark') }}",
        aws_conn_id='aws_default'
    )

    # 4. Terminar cluster
    encerrar_cluster = EmrTerminateJobFlowOperator(
        task_id='encerrar_cluster',
        job_flow_id="{{ task_instance.xcom_pull(task_ids='criar_cluster_emr') }}",
        aws_conn_id='aws_default',
        trigger_rule="all_done"  # encerra mesmo que falhe
    )

    fim = DummyOperator(task_id='fim')

    # Encadeamento
    inicio >> criar_cluster >> adicionar_step >> monitorar_step >> encerrar_cluster >> fim
