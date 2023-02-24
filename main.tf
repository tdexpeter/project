provider "aws" {
  region     = "us-east-1"
  access_key = AWS_ACCESS_KEY_ID
  secret_key = AWS_SECRET_ACCESS_KEY
}

# Creating VPC

resource "aws_vpc" "tdex-projectvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tdex-project"
  }
}

#Creating Subnet

resource "aws_subnet" "tdex-project_sub" {
  vpc_id     = aws_vpc.tdex-projectvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tdex-project"
  }
}

resource "aws_subnet" "tdex-project2_sub" {
  vpc_id     = aws_vpc.tdex-projectvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "tdex-project"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "tdex-project_gw" {
  vpc_id = aws_vpc.tdex-projectvpc.id

  tags = {
    Name = "tdex-project"
  }
}

resource "aws_route_table" "tdex-project_route" {
  vpc_id = aws_vpc.tdex-projectvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tdex-project_gw.id
  }

  tags = {
    Name = "tdex-project"
  }
}

#Security group

resource "aws_security_group" "tdex-project_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tdex-projectvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.tdex-projectvpc.cidr_block]
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

resource "aws_network_interface" "tdex-project_ni" {
  subnet_id       = aws_subnet.tdex-project_sub.id
  security_groups = [aws_security_group.tdex-project_sg.id]

  

}

resource "aws_instance" "tdex-project_web" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  tags = {
    Name = "tdex-project"
  }
}

#load balancer

resource "aws_lb" "tdex-project_lb" {
  name               = "tobi-project-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tdex-project_sg.id]
  subnets            = [aws_subnet.tdex-project_sub.id , aws_subnet.tdex-project2_sub.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}