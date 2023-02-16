provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAQMKOIB224ACVRTPR"
  secret_key = "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"
}

# Creating VPC

resource "aws_vpc" "open-react-templatevpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "open-react-template"
  }
}

#Creating Subnet

resource "aws_subnet" "open-react-template_sub" {
  vpc_id     = aws_vpc.open-react-templatevpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "open-react-template"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "open-react-template_gw" {
  vpc_id = aws_vpc.open-react-templatevpc.id

  tags = {
    Name = "open-react-template"
  }
}

resource "aws_route_table" "open-react-template_route" {
  vpc_id = aws_vpc.open-react-templatevpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.open-react-template_gw.id
  }

  tags = {
    Name = "open-react-template"
  }
}

#Security group

resource "aws_security_group" "open-react-template_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.open-react-templatevpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.open-react-templatevpc.cidr_block]
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

resource "aws_network_interface" "open-react-template_ni" {
  subnet_id       = aws_subnet.open-react-template_sub.id
  security_groups = [aws_security_group.open-react-template_sg.id]

  

}

resource "aws_instance" "open-react-template_web" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  tags = {
    Name = "open-react-template"
  }
}