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

resource "aws_instance" "example" {
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance-test-1.id]
    tags = {
      Name = "terraform-example"
    }
    user_data = <<-EOF
      #!/bin/bash
      echo "Scott is a poopoo head" > index.html
      nohup busybox httpd -f -p 8080 &
      EOF
    user_data_replace_on_change = true
}

resource "aws_security_group" "instance-test-1" {
  name = "terraform-example-instance"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}