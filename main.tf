provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAQMKOIB22Q2EBIWPG"
  secret_key = "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"
}

# Creating VPC

resource "aws_vpc" "tobi-projectvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tobi-project"
  }
}

#Creating Subnet

resource "aws_subnet" "tobi-project_sub" {
  vpc_id     = aws_vpc.tobi-projectvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tobi-project"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "tobi-project_gw" {
  vpc_id = aws_vpc.tobi-projectvpc.id

  tags = {
    Name = "tobi-project"
  }
}

resource "aws_route_table" "tobi-project_route" {
  vpc_id = aws_vpc.tobi-projectvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tobi-project_gw.id
  }

  tags = {
    Name = "tobi-project"
  }
}

#Security group

resource "aws_security_group" "tobi-project_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tobi-projectvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.tobi-projectvpc.cidr_block]
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

resource "aws_network_interface" "tobi-project_ni" {
  subnet_id       = aws_subnet.tobi-project_sub.id
  security_groups = [aws_security_group.tobi-project_sg.id]

  

}

resource "aws_instance" "tobi-project_web" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  tags = {
    Name = "tobi-project"
  }
}