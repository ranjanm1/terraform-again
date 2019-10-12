provider "aws" {
    region = "eu-west-2"
}

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

resource "aws_security_group" "terra_web_sg" {
    name = "terra_web_sg"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value = "${aws_instance.server1.public_ip}"
}