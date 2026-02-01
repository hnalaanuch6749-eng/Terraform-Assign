data "aws_subnets" "private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["${lookup(local.common, "product")}_${lookup(local.common, "sdlcenv")}_${lookup(local.common, "accountenv")}-${var.vpc_function}-privatesubnet"]
  }
}
