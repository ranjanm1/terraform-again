provider "aws" {
    region = "eu-west-2"
}

resource "aws_instance" "server1" {
    ami = "ami-00a1270ce1e007c27"
    instance_type = "t2.micro"
    tags = {
        Name = "terraform-example"
    }
}

