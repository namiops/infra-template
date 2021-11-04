locals {
  config_vars = yamldecode(file(get_env("CONFIG_VARS_YAML", "dev_vars.yaml")))
}

terraform {
  # Terraform to keep trying to acquire a lock for up to 5 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = [
      "-lock-timeout=5m"
    ]
  }

  extra_arguments "conditional_vars" {
    commands = [ "apply", "plan", "import", "push", "refresh"]
    optional_var_files = [
      "${get_terragrunt_dir()}/${get_env("TF_VAR_config", "terraform")}.tfvars"
    ]
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "ap-northeast-1"
}
EOF
}


remote_state {
  backend = "s3"
  config = {
    ## company-project_name-infra-env-state
    bucket         = "${local.config_vars.common.company}-${local.config_vars.common.project_name}-${local.config_vars.common.environment}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.config_vars.aws.region}"
    encrypt        = true 
    dynamodb_table = "${local.config_vars.common.company}-${local.config_vars.common.project_name}-infra-${local.config_vars.common.environment}-table"
    profile        = "${local.config_vars.aws.profile}"
  }
}