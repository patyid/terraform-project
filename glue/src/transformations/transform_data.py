from pyspark.sql import DataFrame
from pyspark.sql.functions import col, date_format

from pyspark.sql.types import DecimalType

def transform_data(spark,input_path) -> DataFrame:

    df = (
        spark.read.option("header", "true").csv(input_path+ "transactions_dataset.csv")
        .withColumn("month_transaction", date_format(col("date_transaction"), "yyyy-MM"))      
        .withColumn("amount", col("amount").cast(DecimalType(precision=8, scale=2)))
    )
    return df

