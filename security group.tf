terraform {
    required_provider {
        aws = {
            source = "hashicorp/aws"
            version = "5.94.1"
        }
    }
}

provider "aws"{
    region = ""
    access_key = ""
    secret_key = ""
}

// CREATING A SECURITY GROUP

resource "aws_security_group" "instance-sg" {
    name = "instance-sg"
    description = "This is created using terraform"
    vpc_id = ""

    ingress{
        description = "This is the first inbound rule"
        form_port = "443"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        description = "This is egress rule"
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cider_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "instance-sg"
        author = "savio"
        date="15.09.2025"
    }
}

// CREATING A INSTANCE

resource "aws_instance" "my-instance" {
    ami = "ami-"
    instance_type = ""
    key_name = ""
    vpc_security_group_ids = [aws_security_group.instance-sg.id]
    tags = {
        name = "my-instance"
    }
}

// CREATING EBS VOLUMES

resource "aws_ebs_volume" "ebs-volume" {
    avalibility_zone = "us-east-2a"
    size = "5"
    tags = {
        name = "ebs-volume"
    }
}

// ATTACHING EBS VOLUME TO EC2 INSTANCE

resource "aws_volume_attachment" "volume-5gb-attach" {
    volume_id = aws_ebs_volume.ebs-volume.id
    instance_id = aws_instance.my-instance.id
    device_name = "/dev/sde"
}