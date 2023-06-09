#Creates the VPC and configures it using the variable VPC object definitions
#owner: Alexandre Cezar

resource "aws_vpc" "pcfw-foundations-vpc" {
  cidr_block = var.vpc.pcfw_foundations_vpc.cidr_block
  tags = {
    Name = var.vpc.pcfw_foundations_vpc.name
  }
}

#Creates the public subnet using the variable public subnet object definitions
resource "aws_subnet" "public-subnet" {
  cidr_block = var.public_subnet.cidr_block
  vpc_id     = aws_vpc.pcfw-foundations-vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "public-subnet"
  }
}

#Creates the private subnet using the variable internal subnet object definitions
resource "aws_subnet" "private-subnet" {
  cidr_block = var.internal_subnet.cidr_block
  vpc_id     = aws_vpc.pcfw-foundations-vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "private-subnet"
  }
}

#Creates the 2nd private subnet using the variable internal2 subnet object definitions
resource "aws_subnet" "private2-subnet" {
  cidr_block = var.internal2_subnet.cidr_block
  vpc_id     = aws_vpc.pcfw-foundations-vpc.id
  availability_zone = "us-west-2c"
  tags = {
    Name = "private2-subnet"
  }
}

#Creates the 1st LB subnet using the variable lb1 subnet object definitions
resource "aws_subnet" "lb1-subnet" {
  cidr_block = var.lb1_subnet.cidr_block
  vpc_id     = aws_vpc.pcfw-foundations-vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "lb1-subnet"
  }
}

#Creates the 2nd LB subnet using the variable lb1 subnet object definitions
resource "aws_subnet" "lb2-subnet" {
  cidr_block = var.lb2_subnet.cidr_block
  vpc_id     = aws_vpc.pcfw-foundations-vpc.id
  availability_zone = "us-west-2c"
  tags = {
    Name = "lb2-subnet"
  }
}

#Creates the Internet Gateway
resource "aws_internet_gateway" "pcfw-foundations-igw" {
  vpc_id = aws_vpc.pcfw-foundations-vpc.id
  tags = {
    Name = "pcfw-foundations-igw"
  }
}

#Creates the NAT Gateway
resource "aws_nat_gateway" "pcfw-foundations-nat-gw" {
  allocation_id = aws_eip.pcfw-foundations-eip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "pcfw-foundations-nat-gw"
  }
}

#Creates an Elastic IP and attaches it with the NAT Gateway
resource "aws_eip" "pcfw-foundations-eip" {
  vpc = true
  tags = {
    Name = "pcfw-eip-natgw"
  }
}

#Creates the private subnet routing table
resource "aws_route_table" "pcfw-private" {
  vpc_id = aws_vpc.pcfw-foundations-vpc.id
  tags = {
    Name = "pcfw-private"
  }
}

#Configures the default route of private subnet pointing to the NAT Gateway
resource "aws_route" "private_default_route" {
  route_table_id         = aws_route_table.pcfw-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.pcfw-foundations-nat-gw.id
}

#Creates the public subnet routing table
resource "aws_route_table" "pcfw-public" {
  vpc_id = aws_vpc.pcfw-foundations-vpc.id
  tags = {
    Name = "pcfw-public"
  }
}

#Configures the default route of public subnet pointing to the Internet Gateway
resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.pcfw-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pcfw-foundations-igw.id
}

#Associates the private route table with the private subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.pcfw-private.id
}

#Associates the private route table with the private2 subnet
resource "aws_route_table_association" "private2_association" {
  subnet_id      = aws_subnet.private2-subnet.id
  route_table_id = aws_route_table.pcfw-private.id
}

#Associates the public route table with the public subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.pcfw-public.id
}

#Creates the lb subnets routing table
resource "aws_route_table" "pcfw-lb" {
  vpc_id = aws_vpc.pcfw-foundations-vpc.id
  tags = {
    Name = "pcfw-lb"
  }
}

#Configures the default route of lb subnet pointing to the Internet Gateway
resource "aws_route" "lb_default_route" {
  route_table_id         = aws_route_table.pcfw-lb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pcfw-foundations-igw.id
}

#Associates the lb route table with the lb1 subnet
resource "aws_route_table_association" "lb1_association" {
  subnet_id      = aws_subnet.lb1-subnet.id
  route_table_id = aws_route_table.pcfw-lb.id
}

#Associates the lb route table with the lb2 subnet
resource "aws_route_table_association" "lb2_association" {
  subnet_id      = aws_subnet.lb2-subnet.id
  route_table_id = aws_route_table.pcfw-lb.id
}