terraform {
  source = "../../modules/storage//s3_buckets"
}

locals {
  config_vars = yamldecode(file("${find_in_parent_folders(get_env("CONFIG_VARS_YAML", "dev_vars.yaml"))}"))
}

include {
  path = find_in_parent_folders()
}

inputs = {
  company       = local.config_vars.common.company
  project       = local.config_vars.common.project_name
  environment   = local.config_vars.common.environment
  component     = "s3_bucket"

  bucket_list = contains(keys(local.config_vars.s3), "bucket_list") ?  local.config_vars.s3.bucket_list : []
}