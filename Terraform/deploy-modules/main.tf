######################################## VPC with private subnet ###########################
module "vpc" {
  common       = local.common
  vpc_function = var.vpc_function

  source             = "../modules/terraform-aws-vpc"
  vpc_cidrblock      = var.vpc_cidrblock
  availability_zones = var.availability_zones

  private_subnet_cidr = var.private_subnet_cidr
  enable_nat_gateway  = var.enable_nat_gateway
  public_subnet_cidr  = var.public_subnet_cidr
}



module "lambda_schedule" {
  common               = local.common
  source               = "../modules/terraform-aws-lambda"
  lambda_functionrole  = var.lambda_functionrole
  schedule_expression  = var.schedule_expression
  schedule_description = var.schedule_description
  enabled              = var.enabled
  cw_eventrulename     = var.cw_eventrulename
}

module "snapshot_cleanup" {
  source              = "../modules/snapshot-cleanup-lambda"
  common              = local.common
  lambda_functionname = var.lambda_functionname
  days_old            = var.days_old
  enable_schedule     = var.enable_schedule
  schedule_expression = var.schedule_expressionsnapshot
  security_group_ids  = [aws_security_group.lambda.id]
  subnet_ids          = data.aws_subnets.private_subnet.ids
}



resource "aws_security_group" "lambda" {
  name = "${lookup(local.common, "product")}_${lookup(local.common, "sdlcenv")}_${lookup(local.common, "accountenv")}-${var.lambda_functionname}-SG"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
