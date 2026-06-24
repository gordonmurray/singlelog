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
  default = "t4g.medium"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

source "amazon-ebs" "clickhouse" {
  profile               = var.profile
  region                = var.region
  instance_type         = var.instance_type
  ami_name              = "clickhouse"
  ami_description       = "ClickHouse search layer for singlelog"
  ssh_username          = "ubuntu"
  vpc_id                = var.vpc_id
  subnet_id             = var.subnet_id
  force_deregister      = true
  force_delete_snapshot = true

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
    Name = "clickhouse"
  }
}

build {
  sources = ["source.amazon-ebs.clickhouse"]

  provisioner "file" {
    source      = "./files/clickhouse/network.xml"
    destination = "/home/ubuntu/network.xml"
  }

  provisioner "file" {
    source      = "./files/clickhouse/queries.sql"
    destination = "/home/ubuntu/queries.sql"
  }

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg jq awscli",
      "curl -fsSL https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg",
      "echo 'deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=arm64] https://packages.clickhouse.com/deb stable main' | sudo tee /etc/apt/sources.list.d/clickhouse.list",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server clickhouse-client",
      "sudo mv /home/ubuntu/network.xml /etc/clickhouse-server/config.d/network.xml",
      "sudo systemctl enable clickhouse-server",
    ]
  }
}
