terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
  access_key = "<your access key>"
  secret_key = "<your secret key>"
}

#Creating th VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

#Creating the internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "prod-gateway"
  }
}
#Creating RouteTable
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gateway.id
    }
    
   route {
      ipv6_cidr_block = "::/0"
      gateway_id = aws_internet_gateway.gateway.id
    }  
  tags = {
    Name = "prod-rt"
  }
}

#Creating subnet
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
     Name = "prod-subnet"
   }
}

#Associate subnet with Route Table
resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet-1.id
   route_table_id = aws_route_table.rt.id
 }

#Creating Security Group
resource "aws_security_group" "allow_web" {
  vpc_id = aws_vpc.vpc.id
  name = "allow_web_traffic"
  description = "Allow web inbound traffic"

  ingress {
      description = "HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      description = "SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
 egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "allow_web"
   }

}

 #Create a network interface with an ip in the subnet

#  resource "aws_network_interface" "web-server-nic" {
#    subnet_id       = aws_subnet.subnet-1.id
#    private_ips     = ["10.0.1.50"]
#    security_groups = [aws_security_group.allow_web.id]

#  }

#  Assign an elastic IP to the network interface created in step 7

# resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.web-server-nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on                = [aws_internet_gateway.gateway]
# }




 resource "aws_instance" "foo" {
  ami           = "ami-0c1a7f89451184c8b" 
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "demo-pair"
  associate_public_ip_address = "true"   # Needs to be removed if you use eip
  subnet_id = aws_subnet.subnet-1.id     # Needs to be remoed if you use eip
  security_groups = ["${aws_security_group.allow_web.id}"]    # Needs to be remoed if you use eip


  # network_interface {
  #   network_interface_id = aws_network_interface.web-server-nic.id
  #   device_index         = 0
  # }

user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                 EOF
   tags = {
     Name = "web-server"
   }
 
}
output "server_public_ip" {
   value = aws_instance.foo.public_ip
 }