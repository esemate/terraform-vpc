data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["packer-linux-aws-demo-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["219821615463"]
}

resource "aws_launch_configuration" "terraform-lc" {
  image_id        = "${data.aws_ami.ami.id}"
  instance_type   = "t2.micro"
  iam_instance_profile = "arn:aws:iam::219821615463:instance-profile/CloudWatchAgentServerRole"
  key_name = "ets-k2"
  # key_name = "${aws_key_pair.terraform-key.key_name}"
  # security_groups = ["sg-00588b63a2e2718ca", "sg-02dba30c3edc4093b", "sg-037fe6d4f49b8192f", "sg-04aa8c4a526d70514"]
  security_groups = ["${aws_security_group.terraform-k2-front-sg.id}","${aws_security_group.terraform-k2-ssh-sg.id}"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "terraform-tg" {
  name     = "terraform-tg"
  port     = 8029
  protocol = "HTTP"  
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  health_check {
    protocol = "HTTP"
    port     = 8029
    path     = "/health"
    # matcher  = "200-399" # do not change
    # timeout  = 6         # do not change
  }
}

resource "aws_autoscaling_group" "terraform-asg" {
  name                 = "asg-${aws_launch_configuration.terraform-lc.name}"
  launch_configuration = "${aws_launch_configuration.terraform-lc.name}"    
  vpc_zone_identifier = ["${aws_subnet.terraform-subnet-public-1.id}","${aws_subnet.terraform-subnet-public-2.id}","${aws_subnet.terraform-subnet-public-3.id}"]
  min_size             = 1
  max_size             = 2
  health_check_type = "ELB"
  target_group_arns = ["${aws_lb_target_group.terraform-tg.arn}"]  

  lifecycle {
    create_before_destroy = true
  }  
}

resource "aws_autoscaling_policy" "terraform-asp" {
  name = "terraform-asp"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = "${aws_autoscaling_group.terraform-asg.name}"    

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}

data "aws_availability_zones" "allzones" {
  # state = "available"
}

resource "aws_lb" "terraform-lb" {
  name               = "terraform-lb"
  internal           = false
  load_balancer_type = "application"  
  security_groups = ["${aws_security_group.terraform-k2-front-lb-sg.id}"]    
  subnets = ["${aws_subnet.terraform-subnet-public-1.id}", "${aws_subnet.terraform-subnet-public-2.id}","${aws_subnet.terraform-subnet-public-3.id}"]
}

resource "aws_lb_listener" "terraform-listener" {
  load_balancer_arn = aws_lb.terraform-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn  = "arn:aws:acm:eu-west-1:219821615463:certificate/5fb574c9-ce3e-401f-a0df-d8ec0cdea541"
  	certificate_arn = "arn:aws:acm:eu-west-1:219821615463:certificate/4e980717-bddb-443e-8395-28a45a1e882c"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-tg.arn
  }
}

