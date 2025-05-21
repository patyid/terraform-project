from pyspark.sql import DataFrame
from pyspark.sql.functions import col, date_format
from app.glue.src.constants import constants
from pyspark.sql.types import DecimalType

def transform_data(spark,filename) -> DataFrame:

    df = (
        spark.read.option("header", "true").csv(constants.RAW + filename)
        .withColumn("month_transaction", date_format(col("date_transaction"), "yyyy-MM"))      
        .withColumn("amount").cast(DecimalType(precision=8, scale=2))
    )

