terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_lightsail_key_pair" "clb_server" {
  name       = "clb_server_key_pair"
  public_key = file("~/.ssh/clb_server.pub")
}

resource "aws_lightsail_instance" "clb_server" {
  depends_on = [aws_lightsail_key_pair.clb_server]
  name              = "clb_server_instance"
  availability_zone = "ap-northeast-1c"
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_2_0"
  key_pair_name     = "clb_server_key_pair"
}

resource "aws_lightsail_instance_public_ports" "clb_server" {
  instance_name = aws_lightsail_instance.clb_server.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "tcp"
    from_port = 8085
    to_port   = 8085
  }

  port_info {
    protocol  = "tcp"
    from_port = 8086
    to_port   = 8086
  }

  port_info {
    protocol  = "tcp"
    from_port = 8087
    to_port   = 8087
  }

}

resource "null_resource" "ansible_exec" {
    depends_on = [aws_lightsail_instance.clb_server]
    provisioner "local-exec" {
		working_dir = "${path.module}"
        command = <<EOF
			set -x

			export clb_user=${aws_lightsail_instance.clb_server.username}
			export clb_ip=${aws_lightsail_instance.clb_server.public_ip_address}

			export ANSIBLE_PERSISTENT_CONNECT_TIMEOUT=9999
			export ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=9999
			export ANSIBLE_HOST_KEY_CHECKING=False 

			rm -f inventory client.clb

            echo "clb_server ansible_port=22 ansible_host=$clb_ip ansible_user=$clb_user ansible_ssh_private_key_file=~/.ssh/clb_server" > inventory
            
			while ! ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/clb_server $clb_user@$clb_ip whoami;
			do
				sleep 1s
			done

			unset clb_user
			unset clb_ip

            ansible-playbook -i inventory playbook.yaml -v

			unset ANSIBLE_PERSISTENT_CONNECT_TIMEOUT
			unset ANSIBLE_PERSISTENT_COMMAND_TIMEOUT
			unset ANSIBLE_HOST_KEY_CHECKING

			set +x
        EOF
    }
}

output "server_ip" {
  value = aws_lightsail_instance.clb_server.public_ip_address
}

