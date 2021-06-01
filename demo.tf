// terraform plan, terraform apply
// even if do terraform apply twice, we will get only one instance of aws as we specified only one resource "aws_instance" "terrafrom-ec2" 
// terraform destory -> will destory all the resouces it created
//we can destory specific instance by specifying a paramter or we comment a resource and that resouce will be removed from infrastructure
// the order in which you place your resouces in code doesn't matter
// the state that we mention in terraform is present in terraform.tfstate, never mess with tfstate file
/*
provider "aws" {
    region = "**************"
    access_key = "**************"
    secret_key = "**************"

}
*/
/*
How to create a resouce
resource "<provider> <resouce_type>" "name" {
    config options....
    key = "value"
    key2 = "value-value"
}
*/
// deploy Ec2 instance
/*resource "aws_instance" "terrafrom-ec2" {
    ami = "ami-0d5eff06f840b45e9"
    instance_type = "t2.micro"
    tags = { // tag is map of key value pair
      Name = "terrafrom-ec2"
    }
  
}*/
/*
resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "prod-vpc"
    }
  
}
// we can refer to other resouces through their name, and access a partiular property of it.
resource "aws_subnet" "demo-subnet" {

    vpc_id = aws_vpc.demo-vpc.id // this how we can refer to other resources, here we are refering to a vpc
     cidr_block = "10.0.0.0/16"
       tags = {
      Name = "demo-subnet"
    }
  
}
*/