import math
import pickle

HDFS_BLOCK_SIZE_128MB_IN_BYTES = 128 * 1024 * 1024  # 128 MB em bytes

def get_bytes(row):
    try:
        return len(pickle.dumps(row.asDict(), protocol=pickle.HIGHEST_PROTOCOL))
    except Exception as e:
        print("Erro ao calcular bytes:", e)
        return None

def get_partition_size(bytes_per_row: int, count_dataset: int) -> int:
    print(f"bytes_per_row -> {bytes_per_row}")
    total_size_dataset = bytes_per_row * count_dataset
    result = math.ceil(total_size_dataset / HDFS_BLOCK_SIZE_128MB_IN_BYTES)
    return max(result, 1)

#add save dataset function em parquet
def save_dataset_parquet(df, path):
    try:
        sample_row = df.limit(1).collect()[0]
        bytes_per_row = get_bytes(sample_row)
        row_count = df.count()
        num_partitions = get_partition_size(bytes_per_row, row_count)
        df.write \
            .mode("overwrite") \
            .repartition(num_partitions) \
            .partitionBy("month_transaction") \
            .parquet(path)
    except Exception as e:
        print("Erro ao salvar o dataset:", e)

