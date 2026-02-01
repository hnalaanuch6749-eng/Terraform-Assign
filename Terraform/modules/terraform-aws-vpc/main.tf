################################# VPC ##############################

resource "aws_vpc" "myawesomevpc" {
  cidr_block           = var.vpc_cidrblock
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.vpc_function}-vpc"
  }
}


################################## Internet Gateway #######################
resource "aws_internet_gateway" "myawesomeigw" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.myawesomevpc.id

  tags = {
    Name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.vpc_function}-igw"
  }
}

################################# Public Subnet #############################
resource "aws_subnet" "public" {
  count                   = var.enable_nat_gateway ? 1 : 0
  vpc_id                  = aws_vpc.myawesomevpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.vpc_function}-publicsubnet"
  }
}

resource "aws_route_table" "public" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.myawesomevpc.id
}

resource "aws_route" "public_igw" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myawesomeigw[0].id
}


resource "aws_route_table_association" "public" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}


########################### NAT Gateway #######################
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "myawesomengw" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.myawesomeigw]
}


########################################### Private Subnet ################

resource "aws_subnet" "private" {
  count                   = var.enable_nat_gateway ? 1 : 0
  vpc_id                  = aws_vpc.myawesomevpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${lookup(var.common, "product")}_${lookup(var.common, "sdlcenv")}_${lookup(var.common, "accountenv")}-${var.vpc_function}-privatesubnet"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myawesomevpc.id
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.myawesomengw[0].id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private.id
}
