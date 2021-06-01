/*
In this file, a simple infrastructure to set up in aws.
1) Create a VPC
2) Create a internet gateway
3) Create a custom routing table
4) Create a subnet
5) Assocaite subnet with routing table
6) Create a security group to allow port 22,80,443
7) Create a network interface with an ip in the subnet that was created in step 4
8) Assign an elastic ip to the network interface created in step 7
9) Create ubuntu server and install/enable apache2
*/

provider "aws" {
    region = "**************"
    access_key = "**************"
    secret_key = "**************"

}

// create  a vpc
resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "prod-vpc"
    }
  
}
// internet gateway
resource "aws_internet_gateway" "demo-internet-gateway" {

    vpc_id = aws_vpc.demo-vpc.id
  
}
// routing table
 resource "aws_route_table" "demo-route-table" {
   vpc_id = aws_vpc.demo-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.demo-internet-gateway.id
   }

   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.demo-internet-gateway.id
   }

   tags = {
     Name = "demo-routing"
   }

 }

 // create a subnet
 resource "aws_subnet" "demo-subnet" {

    vpc_id = aws_vpc.demo-vpc.id // this how we can refer to other resources, here we are refering to a vpc
     cidr_block = "10.0.0.0/16"
       tags = {
      Name = "demo-subnet"
    }
    availability_zone = "us-east-1a"
  
}
//assocate subnet with route table

resource "aws_route_table_association" "demo-routing-tb-assoc" {
   subnet_id      = aws_subnet.demo-subnet.id
   route_table_id = aws_route_table.demo-route-table.id
 }

 //security group

 resource "aws_security_group" "demo-allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.demo-vpc.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
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

resource "aws_network_interface" "demo-web-server-nic" {
   subnet_id       = aws_subnet.demo-subnet.id
   private_ips     = ["10.0.1.50"] // some are reserved by aws
   security_groups = [aws_security_group.demo-allow_web.id]

 }

// Assign an elastic IP to the network interface created in step 7

 resource "aws_eip" "demo-eip" {
   vpc                       = true
   network_interface         = aws_network_interface.demo-web-server-nic.id
   associate_with_private_ip = "10.0.1.50"
   depends_on                = [aws_internet_gateway.demo-internet-gateway]
 }

//demo-ec2
 resource "aws_instance" "demo-ec2" {
    ami = "ami-0d5eff06f840b45e9"
    instance_type = "t2.micro"
    tags = { 
      Name = "terrafrom-ec2"
    }
    availability_zone = "us-east-1a"
   key_name = "**************"
   network_interface {
     
     device_index= 0
     network_interface_id=aws_network_interface.demo-web-server-nic.id
   }
   # by this we write from script in user data
 /*user_data = <<- EOF
		#! /bin/bash
                sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
*/

}
