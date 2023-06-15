#terraform {
#  required_providers {
#    aws = {
#        source = "hashicorp/aws"
#        version = "~> 4.0"
#        
#    }
#  }
#  
#}


provider "aws" {
    region = "us-east-2"
}

resource "aws_launch_configuration" "example" {
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance-test-1.id]
    tags = {
      Name = "terraform-example"
    }
    user_data = <<-EOF
      #!/bin/bash
      echo "Mikey is a poopoo head" > index.html
      nohup busybox httpd -f -p var.server_port &
      EOF
    # Required when using a launch configuration with an auto scaling group.
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag {
    key = "name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance-test-1" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  # By default, return a 404
  default_action {
    type = "fixed-response"

    fixed-response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc/default.id]
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP of the web server."
}