resource "aws_s3_object" "glue_job_script" {
  bucket = module.script_bucket.bucket_name
  key    = "glue_job_package.zip"
  source = "../script/glue_job_package.zip"
  etag   = filemd5("../script/glue_job_package.zip")
}


module "glue_job" {
  source = "../aws/modules/glue_job"

  glue_job_name       = "transaction-glue-job"
  script_bucket_name  = module.script_bucket.bucket_name
  script_s3_key       = "glue_job_package.zip"
  number_of_workers   = 2
  worker_type         = "G.1X"

  default_arguments = {
    "--job-language"                      = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
    "--input_path"                       = "s3://${module.raw_bucket.bucket_name}/processar/"
    "--output_path"                      = "s3://${module.trusted_bucket.bucket_name}/processar/transaction"
    "--JOB_NAME"                         = "transaction-glue-job"
    "--TempDir"                          = "s3://${module.temp_bucket.bucket_name}/glue_temp/"
  }

  depends_on = [aws_s3_object.glue_job_script]
}
