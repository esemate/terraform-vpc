resource "aws_vpc" "terraform-vpc" {
    cidr_block = "172.69.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"        
    tags = {
        Name = "terraform-vpc"
    }
}

resource "aws_subnet" "terraform-subnet-public-1" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    cidr_block = "172.69.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-1a"
    tags = {
        Name = "terraform-subnet-public-1"
    }
}

resource "aws_subnet" "terraform-subnet-public-2" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    cidr_block = "172.69.2.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-1b"
    tags = {
        Name = "terraform-subnet-public-2"
    }
}

resource "aws_subnet" "terraform-subnet-public-3" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    cidr_block = "172.69.3.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-1c"
    tags = {
        Name = "terraform-subnet-public-3"
    }
}