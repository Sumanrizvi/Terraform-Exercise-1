terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "snakegame-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "suman-snakegame-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.snakegame-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Suman-SnakeGameSubnet-Public"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.snakegame-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Suman-SnakeGameSubnet-Private"
  }
}

resource "aws_internet_gateway" "snakegame-internet-gateway" {
  vpc_id = aws_vpc.snakegame-vpc.id

  tags = {
    Name = "Suman-SnakeGame-InternetGateway"
  }
}

resource "aws_route_table" "snakegame-routetable" {
  vpc_id = aws_vpc.snakegame-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.snakegame-internet-gateway.id
  }

  tags = {
    Name = "Suman-SnakeGame-RouteTable-Public"
  }
}

resource "aws_route_table_association" "snakegame-rt-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.snakegame-routetable.id
}

resource "aws_nat_gateway" "snakegame-natgateway" {
  allocation_id = aws_eip.snakegame-natgateway-elastic-ip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "Suman-SnakeGame-NatGateway"
  }
}

resource "aws_eip" "snakegame-natgateway-elastic-ip" {

  tags = {
    Name = "Suman-SnakeGame-ElasticIP"
  }
}

