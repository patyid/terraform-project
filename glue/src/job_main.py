from pyspark.sql import SparkSession
from glue.src.utils.validate_args import validate_args
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import col
from glue.src.transformations.transform_data import transform_data
from glue.src.utils.dataframe_utils import save_dataset_parquet
import sys

def main():
    # Lista de argumentos esperados
    expected_args = ['JOB_NAME', 'input_path', 'output_path']
    args = getResolvedOptions(sys.argv, expected_args)

    spark = SparkSession.builder.appName(args['JOB_NAME']).getOrCreate()
    glueContext = GlueContext(spark.sparkContext)

    # Validação de argumentos obrigatórios
    validate_args(args, expected_args)

    input_path = args['input_path']
    output_path = args['output_path']

    transformed_df = transform_data(spark, input_path)
    save_dataset_parquet(transformed_df,output_path)
 

    spark.stop()


