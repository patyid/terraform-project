import yaml
from airflow.models import BaseOperator
from airflow.providers.amazon.aws.hooks.emr import EmrHook
from airflow.utils.context import Context


class EmrCreateCustomJobFlowOperator(BaseOperator):
    """
    Operator to create an EMR cluster from a YAML config file.

    :param job_path_config: Path to YAML file with EMR cluster configuration.
    :param aws_conn_id: Airflow AWS connection ID.
    :param emr_conn_id: (Optional) For compatibility; not used.
    :param identifier: Optional string to append to the cluster name.
    """

    def __init__(
        self,
        job_path_config: str,
        aws_conn_id: str = 'aws_default',
        emr_conn_id: str = None,
        identifier: str = "",
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.job_path_config = job_path_config
        self.aws_conn_id = aws_conn_id
        self.emr_conn_id = emr_conn_id
        self.identifier = identifier

    def execute(self, context: Context):
        self.log.info(f"Loading EMR cluster config from: {self.job_path_config}")
        with open(self.job_path_config, 'r') as file:
            config_data = yaml.safe_load(file)

        config = config_data.get('emr', {}).get('config', {})
        if not config:
            raise ValueError("Arquivo YAML inválido ou incompleto (esperado: emr.config)")

        # Montar a configuração para run_job_flow
        name = config.get('name', 'default-cluster') + self.identifier
        version = config.get('version')
        master = config.get('primaryNode', {})
        slave = config.get('slaveNodes', {})
        apps = [{'Name': app} for app in config.get('apps', [])]
        tags = config.get('tags', [])

        configurations = []

        if 'Hadoop' in config.get('apps', []):
            configurations.append({
                "Classification": "hdfs-site",
                "Properties": {"dfs.replication": "2"}
            })

        configurations.append({
            "Classification": "spark",
            "Properties": {"maximizeResourceAllocation": "true"}
        })

        if config.get('glue_data_catalog_config', False):
            self.log.info("Incluindo configuração para Glue Data Catalog.")
            configurations.extend([
                {
                    "Classification": "hive-site",
                    "Properties": {
                        "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
                    }
                },
                {
                    "Classification": "spark-hive-site",
                    "Properties": {
                        "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
                    }
                }
            ])

        cluster_spec = {
            'Name': name,
            'ReleaseLabel': version,
            'LogUri': "s3://seu-bucket-logs/",  # Pode substituir via variáveis ou contexto
            'Applications': apps,
            'Configurations': configurations,
            'Instances': {
                'InstanceGroups': [
                    {
                        'Name': 'Primary node',
                        'Market': 'ON_DEMAND',
                        'InstanceRole': 'MASTER',
                        'InstanceType': master.get('instanceType'),
                        'InstanceCount': master.get('instanceCount', 1)
                    },
                    {
                        'Name': 'Slave nodes',
                        'Market': 'ON_DEMAND',
                        'InstanceRole': 'CORE',
                        'InstanceType': slave.get('instanceType'),
                        'InstanceCount': slave.get('instanceCount', 2)
                    }
                ],
                'KeepJobFlowAliveWhenNoSteps': True,
                'TerminationProtected': False
            },
            'JobFlowRole': "EMR_EC2_DefaultRole",
            'ServiceRole': "EMR_DefaultRole",
            'Tags': tags,
            'VisibleToAllUsers': True
        }

        emr_hook = EmrHook(aws_conn_id=self.aws_conn_id)
        self.log.info("Enviando requisição para criação do cluster EMR...")
        response = emr_hook.conn.run_job_flow(**cluster_spec)

        cluster_id = response['JobFlowId']
        self.log.info(f"Cluster EMR criado com sucesso: {cluster_id}")
        return cluster_id


class EmrAddStepsCustomOperator(BaseOperator):
    """
    Operator to add EMR steps defined in a YAML file, with support for parameter substitution.

    :param job_flow_id: ID of the EMR cluster.
    :param steps_path_config: Path to YAML file with EMR step definitions.
    :param custom_parameters: String of comma-separated values to replace placeholders.
    :param aws_conn_id: Airflow connection ID for AWS.
    :param identifier: Optional string for logging context.
    """

    def __init__(
        self,
        job_flow_id: str,
        steps_path_config: str,
        custom_parameters: str = "",
        aws_conn_id: str = 'aws_default',
        identifier: str = "",
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.job_flow_id = job_flow_id
        self.steps_path_config = steps_path_config
        self.custom_parameters = custom_parameters
        self.aws_conn_id = aws_conn_id
        self.identifier = identifier

    def render_params(self, step, param_values):
        def replace_params(arg):
            if isinstance(arg, str):
                for i, val in enumerate(param_values):
                    arg = arg.replace(f"{{{{ params.param_{i} }}}}", val)
                return arg
            return arg

        step_copy = {}
        for key, value in step.items():
            if isinstance(value, dict):
                step_copy[key] = {k: replace_params(v) for k, v in value.items()}
            elif isinstance(value, list):
                step_copy[key] = [replace_params(v) for v in value]
            else:
                step_copy[key] = replace_params(value)
        return step_copy

    def execute(self, context: Context):
        self.log.info(f"Lendo arquivo de steps: {self.steps_path_config}")
        with open(self.steps_path_config, 'r') as f:
            raw_steps = yaml.safe_load(f)

        # Trata parâmetros customizados
        param_values = []
        if self.custom_parameters:
            param_values = self.custom_parameters.split(",")

        steps = []
        for step in raw_steps:
            rendered = self.render_params(step, param_values)
            steps.append(rendered)

        self.log.info(f"Adicionando {len(steps)} step(s) ao cluster {self.job_flow_id}...")
        emr_hook = EmrHook(aws_conn_id=self.aws_conn_id)
        response = emr_hook.conn.add_job_flow_steps(JobFlowId=self.job_flow_id, Steps=steps)

        step_ids = response['StepIds']
        self.log.info(f"Step(s) adicionados com sucesso: {step_ids}")
        return step_ids[0] if len(step_ids) == 1 else step_ids
