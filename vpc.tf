terraform { 
    required_providers {
      aws= {
        source = "value"
        version = "value"
      }
    }
}

provider "aws" {
  region = ""
  access_key = ""
  secret_key = ""
}

// HERE WE CREATE VPC

resource "aws_vpc" "terraform-vpc" {
    cidr_block = "12.0.0.0/16"
    instance_tenancy = "default"
    tags {
        name = "terraform-vpc"
    }

}

// HERE WE CREATE INTERNET GATEWAY


resource "aws_internet_gateway" "Terraform-Internet-Gateway" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    name ="Terraform-Internet-Gateway"
  }
}

// CREATING PUBLIC SUBNET

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "us-east-2a"
  cidr_block = "12.0.1.0/26"
  tags = {
    name = "public-subnet"
  }
}

//  CREATING PRIVATE SUBNET

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.terraform-vpc.id
  availability_zone = "us-east-2a"
  cidr_block ="12.0.2.0/26"
  tags = {
    name = "Private-subnet"
  }
}

// Here we create security group wuth ssh http https 

resource "aws_security_group" "public-security-group" {
  name = "public-security-group"
  description = "This is public security group"
  vpc_id = aws_vpc.Terraform-vpc.id
  
  ingress {
    description = "This is ssh rule"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "This is http rule"
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "This is ssh rule"
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    from_port = "0"
    to_port = "0"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }
  tags {
    name = "Public-Security-Group"
  }
}

// HERE WE CREATE PUBLIC INSTANCE

resource "aws_instance" "public-instance"{
  ami = ""
  instance_type = "t2.micro"
  key_name = ""
  security_groups = [aws_security_group.public-security_group.id]
  subnet_id = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  user_data =<<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt install nginx -y
sudo rm-rf /var/www/html/*
echo " <h1> Hello this is public instance in public subnet</h1> > /var/www/html/index.html
EOF
}

// HERE WE CREATE PRIVATE SUBNET

resource "aws_instance" "private-instance" {
  ami = ""
  instance_type = "t2.micro"
  key_name = ""
  security_groups = [aws_security_group.public-security-group.id]
  subnet_id = aws_subnet.private-subnet.id
  associate_public_ip_address = false
  tags = {
    name = "Private-Instance"
  }
}

//  CREATE PUBLIC ROUTE TABLE WITH IN VPC
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "Public-Route-Table"
  }
}

// CREATE PRIVATE ROUTE TABLE

resource "aws_route_table" "private-route-table"{
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    name = "Private-Route-Table"
  }
}

// Pubic RT ASSOCIATE with Public-Subnet

resource "aws_route_table_association" "RT-Public-Association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_subnet_table.public-route-table.id
}

// Private RT ASSOCIATED with Private-Subnet

resource "aws_route_table_association" "RT-Private-Associate" {
  subnet_id = aws_subnet.private-subnet.id 
  route_table_id = aws_route_table.private-route-table.id
}

// ROUTE TABLE IS ROUTED TO INTERNET GATEWAY

resource "aws_route" "RT-Public-IGW" {
  route_table_id = aws_route_table.public-route-table.id
  gateway_id = aws_internet_gateway.Terraform-Internet-Gateway.id 
  destination_cidr_block = "0.0.0.0/0" 
}

// CREATING ELASTIC IP

resource "aws_eip" "elastic-ip" {
  tags = {
    name = "elastic-ip"
  }
}

// CREATING NAT GATEWAY

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.elastic-id.id 
  subnet_id = aws_subnet.public-subnet.id
  connectivity_type = "public"
  tags = {
    name = "NAT-GATEWAY"
  }
}

// ASSOCIATION NAT GATEWAY VIA ROUTE TABLE

resource "aws_route" "private-route-nat-gateway" {
  route_table_id = aws_route_table.private-route-table.id
  gateway_id = aws_nat_gateway.nat-gateway.id
  destination_cidr_block = "0.0.0.0/0" 
}
