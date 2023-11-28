packer {
  required_version = ">= 1.8.0"
  required_plugins {
    amazon = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "ubuntu" {
  filters = {
    virtualization-type = "hvm"
    architecture        = "x86_64"
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "ap-northeast-1"
}

source "amazon-ebs" "ubuntu22-ami" {
  ami_name      = "ubuntu22-weave"
  instance_type = "t3.medium"
  region        = "ap-northeast-1"
  source_ami    = data.amazon-ami.ubuntu.id
  ssh_username  = "ubuntu"
}

build {
  name    = "setup-weave"
  sources = ["source.amazon-ebs.ubuntu22-ami"]

  # Docker
  provisioner "shell" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo curl -L git.io/weave -o /usr/local/bin/weave",
      "sudo chmod 755 /usr/local/bin/weave"
    ]
  }
}
