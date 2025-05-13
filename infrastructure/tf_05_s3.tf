module "raw_bucket" {
  source = "../aws/modules/s3"
  bucket_name = "raw_"+var.id_count

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "trusted_bucket" {
  source = "../aws/modules/s3"
  bucket_name = "trusted_"+var.id_count

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}

module "refined_bucket" {
  source = "../aws/modules/s3"
  bucket_name = "trusted_"+var.id_count

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}
