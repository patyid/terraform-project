module "raw_bucket" {
  source = "../aws/modules/s3"
  bucket_name = "raw-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "trusted_bucket" {
  source = "../aws/modules/s3"
  bucket_name = "trusted-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "refined_bucket" {
  source = "../aws/modules/s3"
  bucket_name = "refined-${var.id_count}"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "raw_prefix" {
  source      = "../aws/modules/s3/prefix"
  bucket_name = module.raw_bucket.bucket_name
  prefix    = [
    "recebimento/",
    "processar/"
  ]
}
