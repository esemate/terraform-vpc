resource "aws_internet_gateway" "terraform-igw" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    tags = {
        Name = "terraform-igw"
    }
}

resource "aws_route_table" "terraform-public-crt" {
    # vpc_id = "${aws_vpc.main-vpc.id}"
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.terraform-igw.id}" 
    }
    
    tags = {
        Name = "terraform-public-crt"
    }
}

resource "aws_route_table_association" "terraform-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.terraform-subnet-public-1.id}"
    route_table_id = "${aws_route_table.terraform-public-crt.id}"
}

resource "aws_security_group" "terraform-k2-ssh-sg" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["2.139.216.88/32"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["88.5.143.141/32"]
    }
    tags = {
        Name = "terraform-k2-ssh-sg"
    }
}

resource "aws_security_group" "terraform-k2-front-sg" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8029
        to_port = 8029
        protocol = "tcp"
        security_groups = ["${aws_security_group.terraform-k2-front-lb-sg.id}"]
    }    
    tags = {
        Name = "terraform-k2-front-sg"
    }
}

resource "aws_security_group" "terraform-k2-front-lb-sg" {
    vpc_id = "${aws_vpc.terraform-vpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
    tags = {
        Name = "terraform-k2-front-lb-sg"
    }
}