module "raw_bucket" {
  source = "../aws/modules/s3_bucket"
  bucket_name = "raw-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "trusted_bucket" {
  source = "../aws/modules/s3_bucket"
  bucket_name = "trusted-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "refined_bucket" {
  source = "../aws/modules/s3_bucket"
  bucket_name = "refined-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "script_bucket" {
  source = "../aws/modules/s3_bucket"
  bucket_name = "script-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "temp_bucket" {
  source = "../aws/modules/s3_bucket"
  bucket_name = "temp-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "trusted_prefix" {
  source      = "../aws/modules/s3_bucket/prefix"
  bucket_name = module.trusted_bucket.bucket_name
  prefix    = [
    "processar/"
  ]
}

module "raw_prefix" {
  source      = "../aws/modules/s3_bucket/prefix"
  bucket_name = module.raw_bucket.bucket_name
  prefix    = [
    "recebimento/",
    "processar/",
  ]
}

module "temp_prefix" {
  source      = "../aws/modules/s3_bucket/prefix"
  bucket_name = module.temp_bucket.bucket_name
  prefix    = [
    "glue_temp/"
  ]
}

#add module s3_bucket_lifecycle
module "temp_lifecycle" {
  source      = "../aws/modules/s3_bucket_lifecycle"
  bucket_id   = module.temp_bucket.id
  prefix    = "temp"
}