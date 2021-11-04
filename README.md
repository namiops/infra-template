# infa-template (TODO - This is temp project, we'll change the name later)

This is a temporary project, we'll use it as a basic template for develop IaC for managing AWS resources of our services and projects.

The core of this template is created to generating a secure network by design, Aws network VPC with Public and Private Subnets (scenario 2), where we'll extend, release and deploy the services under this network setting.
- https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html

![](https://docs.aws.amazon.com/vpc/latest/userguide/images/nat-gateway-diagram.png)

> **_NOTE:_**  It's also easily switch to scenario 3 or 4 if we want, but scenario 2 is recomendation for basic multi-tier application.

The template developed base on the concept in this book "Terraform Up & Running" and using terragrunt as a warpper on top of terraform:
- https://www.terraformupandrunning.com/
- https://terragrunt.gruntwork.io/docs/


![](https://docs.aws.amazon.com/vpc/latest/userguide/images/scenario-2-ipv6-diagram.png)

### Description :
This infrastructure template also inited for support the Microservices Achitect project, where it's going to contain many AWS resources (modules) in the future such as : VPC, EC2 Instances, S3 buckets, Single Static Website, Kafka cluster, Redis elasticache cluster, Aurora Postgresql cluster, queues, EKS ... that could make the template grow rapidly.
So, we need to follow a solid method and rules to develop this template with naming convention, tags, modules structure.

### Features :
- Reusable infrastructure with Terraform Modules
- Dynamic configuration on single centralize yaml config file
- Dynamic sharing outputs between modules
- Code DRY and maintainable
- Concrete naming convention
- Automation GitOps with CI
- Parallel development and ability unittest

### Scope :
- Only work with AWS. We will add others cloud platform modules such as GCP, Azure ...
- Current phase, this template just generate VPC, relate network resource.

### Quick Start :
1. Install Terragrunt ```brew install terragrunt``` (This install will also install terraform)
2. Setup AWS CLI, Access Key and AWS Default profile
3. Run :
    - terragrunt run-all plan --terragrunt-working-dir ./work/


### How to work with this template
This template use terragrunt, an extra terraform grapper, provide some additional tools. And, we should follow its concept:
1. Reusable modules
2. All resources must have standard naming and tags
3. Centralize configuration
4. Team collaborate with Remote State
5. Separate Environment and keep it DRY

#### Read Terragrunt Docs
https://terragrunt.gruntwork.io/docs/

#### Understand the template structure
```
infa-template
├── README.md
├── modules                       #Share and reuse terraform modules
│   └── network
│       └── vpc                   #VPC module with variables and outputs as normal config
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
└── work
    ├── dev_vars.yaml             #Default config file
    ├── network
    │   └── vpc
    │       └── terragrunt.hcl    #Input value to use the module
    ├── provider.tf               #Basic Terraform provider setting
    ├── terraform.tf
    └── terragrunt.hcl            #Root Terragrunt setting
```

#### Config details
Config file is the heart of this template, where the resource value defined.
The default config is dev_vars.yaml, but others environment can be config by select config file:

    ```export CONFIG_VARS_YAML=dev_vars.yaml```


#### Resource naming convention
The common setting in config file will decide the name of our services with basic format :

$company + $project + $environment + $component

    # In config file
    common:
       company       : liquid
       project_name  : qex
       environment   : dev

    ## Usage
    name = "${var.company}-${var.project}-${var.environment}"

##### How define a resource in config file
    Description

        vpc:
           enable  : true
           component   : network               # Name of vpc compoent
           vpc_cidr    : "10.1.0.0/16"         # VPC Cidr
           azs         :                       # Available Zones
             - "ap-northeast-1a"
             - "ap-northeast-1c"
             - "ap-northeast-1d"
           nat_gateway_enabled  : true         # NAT Gateway for every private_subnets
           nat_vpn_enabled      : true         # VPC Gateway for VPN connection to VPC
           subnets:
             public :                          # Public subnet list
               - "10.10.0.0/22"
               - "10.10.4.0/22"
               - "10.10.8.0/22"
             private :                         # Private subnet list
               - "10.10.12.0/22"
               - "10.10.16.0/22"
               - "10.10.20.0/22"

#### Example, How to add an reusable S3 resouces with standard format

1. Init a reuseable terraform module called s3_buckets

File path:
```
modules
── s3_buckets
│   ├── main.tf
│   ├── output.tf
│   └── variables.tf
```
Sample code main.tf
```
resource "aws_s3_bucket" "s3_buckets" {
  count = length(var.bucket_list)

  bucket = "${var.company}-${var.project}-${var.environment}-${var.bucket_list[count.index].name}"
  acl    = var.bucket_list[count.index].acl

  versioning {
    enabled = var.bucket_list[count.index].versioning
  }
  tags = {
    Project     = var.project
    Name        = "${var.company}-${var.project}-${var.environment}-${var.bucket_list[count.index].name}"
    Environment = var.environment
    Component   = var.component
  }
}
```


2. Create terragrunt file to use the s3 module

File Path
```
├s3_buckets
── terragrunt.hcl
```

Sample code terragrunt.hcl
```
 terraform {
  source = "../../modules/s3_buckets"    ##Reusable s3 module
 }

locals {
  config_vars = yamldecode(file("${find_in_parent_folders(get_env("CONFIG_VARS_YAML", "dev_vars.yaml"))}"))   ##Read config file
}

include {
  path = find_in_parent_folders()
}

inputs = {       ## Input value from config file
  company       = local.config_vars.common.company
  project       = local.config_vars.common.project_name
  environment   = local.config_vars.common.environment
  component     = "s3_bucket"

  bucket_list = contains(keys(local.config_vars.s3), "bucket_list") ?  local.config_vars.s3.bucket_list : []
}
```
3. Add config parameters

```
s3:
  bucket_list:
    - name      : "default"
      versioning: true
      acl       : "private"
    - name      : "public_bucket_1"
      versioning: true
      acl       : "publi"
    - name      : "private_bucket_2"
      versioning: true
      acl       : "public"
```

4. Run init, test, plan and apply

```
## Stand at root project dir
terragrunt run-all init
terragrunt run-all test
terragrunt run-all plan
```

## Neat feature: We can remap the resources already existing in AWS by terragrunt import
We can import the resources, which didn't have standard configuration in AWS. Then, we can re-apply the right setting back to existing resources to update.


 1. First, change common setting parameters in config yaml : commpany, project_name, environment
 2. Update vpc_cidr config same with the VPC you want to map:
    ``vpc_cidr    : "10.10.0.0/16"``
 3. Import existing VPC id :

    ```
        $ cd ./network/vpc/
        $ terragrunt import  module.vpc.aws_vpc.this[0] vpc-xxxxxxxxxx
    ```
 4. Run plan to check if the imported VPC is same
    ``$ terragrunt plan``
 5. Go back to work directory, checking which services you want to generate into imported VPC then you can apply change
    ``$ terragrunt run-all plan``
