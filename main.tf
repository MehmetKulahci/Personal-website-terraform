terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.63.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "Static-Web-VPC" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-VPC"
  }
}

resource "aws_subnet" "public1A" {
  vpc_id            = aws_vpc.Static-Web-VPC.id
  availability_zone = var.avail_zone
  cidr_block        = var.pub_sub1a
  tags = {
    Name = "${var.env_prefix}-Subnet1a"
  }
}

resource "aws_subnet" "public1B" {
  vpc_id            = aws_vpc.Static-Web-VPC.id
  availability_zone = var.avail_zone2
  cidr_block        = var.pub_sub1b
  tags = {
    Name = "${var.env_prefix}-Subnet1b"
  }
}


resource "aws_internet_gateway" "Static-Web-İGW" {
  vpc_id = aws_vpc.Static-Web-VPC.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "Static-Web-Public-RT" {
  vpc_id = aws_vpc.Static-Web-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Static-Web-İGW.id
  }
  tags = {
    Name = "${var.env_prefix}-Public-RT"
  }
}

resource "aws_route_table_association" "Static-Sub1a-as" {
  subnet_id      = aws_subnet.public1A.id
  route_table_id = aws_route_table.Static-Web-Public-RT.id
}

resource "aws_route_table_association" "Static-Sub1b-as" {
  subnet_id      = aws_subnet.public1B.id
  route_table_id = aws_route_table.Static-Web-Public-RT.id
}


resource "aws_security_group" "Static-Web-sg" {
  name        = "Static-Web-sg"
  description = "Allow HTTP and SSH port"
  vpc_id      = aws_vpc.Static-Web-VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
    Name = "${var.env_prefix}-sg"
  }
}

resource "aws_lb_target_group" "Static-Web-tg" {
  name     = "Static-Web-tg"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Static-Web-VPC.id
}

resource "aws_lb" "Static-Web-ELB" {
  name               = "Static-Web-ELB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Static-Web-sg.id]
  subnets            = [aws_subnet.public1A.id, aws_subnet.public1B.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "Static-Web-listener" {
  load_balancer_arn = aws_lb.Static-Web-ELB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Static-Web-tg.arn
  }
}

resource "aws_launch_template" "Static-Web-LT" {
  name                                 = "StaticLT"
  image_id                             = var.Static_image_id
  instance_type                        = var.Static_instance_type
  key_name                             = var.Static_key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.Static-Web-sg.id]
  }


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env_prefix}-LT"
    }
  }

  user_data = filebase64("user-data.sh")

}

resource "aws_autoscaling_group" "Static-Web-asg" {
  vpc_zone_identifier = [ aws_subnet.public1A.id, aws_subnet.public1B.id ]
  desired_capacity          = 1
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.Static-Web-tg.arn]

  launch_template {
    id      = aws_launch_template.Static-Web-LT.id
    version = "$Latest"
  }
}

data "aws_route53_zone" "mehmet-hosted_zone" {
  name         = "mehmetspage.click" 
  private_zone = false
}

resource "aws_route53_record" "mehmets-record" {
  zone_id = "Z0191374EX6AVFUDVI4"
  name    = "www.mehmetspage.click"
  type    = "A"

  alias {
    name                   = aws_lb.Static-Web-ELB.dns_name
    zone_id                = aws_lb.Static-Web-ELB.zone_id
    evaluate_target_health = false
  }
}