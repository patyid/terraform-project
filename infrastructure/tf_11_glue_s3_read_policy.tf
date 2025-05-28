module "glue_s3_full_access" {
  source      = "../aws/modules/policies/glue_s3_full_policy"
  policy_name = "GlueS3FullAccess"
  role_name   = module.glue_job.glue_role_name
}
