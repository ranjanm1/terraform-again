provider "aws" {
    region = "eu-west-2"
}

data "aws_availability_zones" "all" {}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
/*
resource "aws_instance" "server1" {
    #ami = "ami-00a1270ce1e007c27"
    ami = "ami-0be057a22c63962cb"
    instance_type = "t2.micro"
    vpc_security_group_ids  = ["${aws_security_group.terra_web_sg.id}"]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello World" > index.html
        nohup busybox httpd -f -p "${var.server_port}" &
        EOF
    tags = {
        Name = "terraform-web-server"
    }
}
*/
resource "aws_launch_configuration" "example" {
    #ami = "ami-00a1270ce1e007c27"
    name = "web-config"
    image_id = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    security_groups  = ["${aws_security_group.terra_web_sg.id}"]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello World" > index.html
        nohup busybox httpd -f -p "${var.server_port}" &
        EOF
    /*tags = {
        Name = "terraform-web-server"
    }
    */
    lifecycle {
        create_before_destroy = true
    }
    
}

    resource "aws_security_group" "terra_web_sg" {
    name = "terra_web_sg"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.name}"
    #availability_zones = ["${data.aws_availability_zones.all.names}"]
    availability_zones = ["eu-west-2a", "eu-west-2b"]
    min_size = 2
    max_size = 10

    

    tag {
        key = "Name"
        value = "terraform_asg_example"
        propagate_at_launch = true
    }
    lifecycle {
        create_before_destroy = true
    }
}
/*
output "public_ip" {
    value = "${aws_instance.server1.public_ip}"

}
*/