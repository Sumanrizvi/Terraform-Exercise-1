terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
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

resource "aws_security_group" "ports" {
  name        = "Snake Game"
  description = "Snake Game"
  vpc_id      = aws_vpc.snakegame-vpc.id

  ingress {
    description      = "World to HTTPS"
    from_port        = 0.0.0.0
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.snakegame-vpc.cidr_block]
  }

  ingress {
    description      = "My Computer to SSH"
    from_port        = 76.89.154.56
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.snakegame-vpc.cidr_block]
  }

  ingress {
    description      = "World to HTTPD"
    from_port        = 0.0.0.0
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.snakegame-vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
