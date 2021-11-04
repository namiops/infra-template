#######################################################################################################################
# BASE ON CONFIG PARAMS, THIS MODULE WILL GENERATE :
# vpc, private_subnets, public_subnets, routetables, NAT Gateway, VPN Gateway ...
#
#######################################################################################################################
terraform {
  backend "s3" {
  }
  required_version = "~> 1.0.10"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.10.0" 
  name                    = "${var.company}-${var.project}-${var.environment}"
  intra_subnet_suffix     = "${var.project}-${var.component}"
  public_subnet_suffix    = "${var.project}-${var.component}-public"
  private_subnet_suffix   = "${var.project}-${var.component}-private"

  cidr  = var.cidr
  azs   = var.azs
  enable_ipv6  = var.enable_ipv6

  #Public subnets
  map_public_ip_on_launch = var.map_public_ip_on_launch
  public_subnets          = var.public_subnets
  public_subnet_assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation

  #Private subnets
  private_subnets = var.private_subnets
  private_subnet_assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation

  #NAT and VPN gateway
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_vpn_gateway = var.enable_vpn_gateway

  intra_acl_tags = {
    Environment = var.environment
    Component   = var.component
    Project     = var.project
    Name        = "${var.project}-${var.environment}-acl"
  }

  intra_route_table_tags = {
    Environment = var.environment
    Component   = var.component
    Project     = var.project
    Name        = "${var.project}-${var.environment}-route-table"
  }

  nat_eip_tags = {
    Environment = var.environment
    Component   = var.component
    Project     = var.project
    Name        = "${var.project}-${var.environment}-eip"
  }

  nat_gateway_tags = {
    Environment = var.environment
    Component   = var.component
    Project     = var.project
    Name        = "${var.project}-${var.environment}-nat"
  }

  tags = {
    Environment = var.environment
    Component   = var.component
    Project     = var.project
  }

}
