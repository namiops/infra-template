terraform {
  source = "../../../modules/network//vpc"
}

prevent_destroy = true

locals {
  config_vars = yamldecode(file("${find_in_parent_folders(get_env("CONFIG_VARS_YAML", "dev_vars.yaml"))}"))
}

include {
  path = find_in_parent_folders()
}

inputs = {
  #project_name-env-vpc
  company       = local.config_vars.common.company
  project       = local.config_vars.common.project_name
  environment   = local.config_vars.common.environment
  component     = "network"

  cidr          = local.config_vars.vpc.vpc_cidr
  azs           = local.config_vars.vpc.azs

  public_subnets  = local.config_vars.vpc.subnets.public
  public_subnet_assign_ipv6_address_on_creation = local.config_vars.vpc.subnets.public_subnet_assign_ipv6 

  private_subnets = local.config_vars.vpc.subnets.private
  private_subnet_assign_ipv6_address_on_creation = local.config_vars.vpc.subnets.private_subnet_assign_ipv6

  enable_nat_gateway     = local.config_vars.vpc.enable_nat_gateway
  single_nat_gateway     = local.config_vars.vpc.single_nat_gateway
  one_nat_gateway_per_az = local.config_vars.vpc.one_nat_gateway_per_az
  enable_vpn_gateway     = local.config_vars.vpc.nat_vpn_enabled

  enable_ipv6                     = local.config_vars.vpc.enable_ipv6
  map_public_ip_on_launch         = local.config_vars.vpc.map_public_ip_on_lauch
}