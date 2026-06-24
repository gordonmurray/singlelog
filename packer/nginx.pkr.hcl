packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "profile" {
  type    = string
  default = null
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

source "amazon-ebs" "nginx" {
  profile               = var.profile
  region                = var.region
  instance_type         = var.instance_type
  ami_name              = "nginx"
  ami_description       = "nginx + vector for singlelog"
  ssh_username          = "ubuntu"
  vpc_id                = var.vpc_id
  subnet_id             = var.subnet_id
  force_deregister      = true
  force_delete_snapshot = true

  # Latest Ubuntu 24.04 (noble) arm64 image from Canonical. The old build
  # hardcoded a long-dead AMI id.
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  tags = {
    Name = "nginx"
  }
}

build {
  sources = ["source.amazon-ebs.nginx"]

  provisioner "file" {
    source      = "./files/vector.toml"
    destination = "/home/ubuntu/vector.toml"
  }

  provisioner "file" {
    source      = "./files/nginx.conf"
    destination = "/home/ubuntu/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx-core jq awscli",
      "curl -1sLf https://setup.vector.dev | sudo -E bash",
      "sudo apt-get install -y vector",
      "sudo mv /home/ubuntu/vector.toml /etc/vector/vector.toml",
      "sudo mv /home/ubuntu/nginx.conf /etc/nginx/nginx.conf",
      "sudo chown vector:vector /var/lib/vector/",
    ]
  }
}
