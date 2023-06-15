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
    public_ip = ${var.public_ip}
    vpc_security_group_ids = [aws_security_group.instance-test-1.id]
    tags = {
      Name = "terraform-example"
    }
    user_data = <<-EOF
      #!/bin/bash
      echo "Mikey is a poopoo head" > index.html
      nohup busybox httpd -f -p ${var.server_port} &
      EOF
    user_data_replace_on_change = true
}

resource "aws_security_group" "instance-test-1" {
  name = "terraform-example-instance"

  ingress {
    from_port = ${var.server_port}
    to_port = ${var.server_port}
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}