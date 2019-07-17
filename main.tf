module "vpc" {
  source                    = "git::https://github.com/tmknom/terraform-aws-vpc.git?ref=tags/1.0.0"
  cidr_block                = "${local.cidr_block}"
  name                      = "session-manager"
  public_subnet_cidr_blocks = ["${cidrsubnet(local.cidr_block, 8, 0)}", "${cidrsubnet(local.cidr_block, 8, 1)}"]
  public_availability_zones = ["${data.aws_availability_zones.available.names}"]
}

module "security_group" {
  source = "./modules/security-group"
  group_name = "ci_security_group"
  https_port = "${var.https_port}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "ci_session_manager" {
  source        = "./modules/session-manager/"
  vpc_id        = "${module.vpc.vpc_id}"
  ssm_document_name = "SessionManager-for-Jenkins"
}

module "key_pair" {
  source = "./modules/generate-key-pair"
  key_name = "jenkins"
}

resource "aws_instance" "ci" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${module.key_pair.key_name}"
  vpc_security_group_ids = ["${concat(list(module.ci_session_manager.security_group_id), module.security_group.id)}"]
  iam_instance_profile = "${module.ci_session_manager.iam_instance_profile_name}"
  subnet_id = "${element(module.vpc.public_subnet_ids, 0)}"

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.key_pair.private_key}"
  }

  provisioner "file" {
    source = "./https-certificate"
    destination = "/var/tmp/https-certificate"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c 'sudo apt-get update'",
      "/bin/bash -c 'sudo apt -y install docker.io'",

      "/bin/bash -c 'sudo service docker start'",
      "/bin/bash -c 'sudo groupadd docker'",
      "/bin/bash -c 'sudo usermod -a -G docker ubuntu'",
      "/bin/bash -c 'sudo systemctl restart docker'",
      "/bin/bash -c 'sudo chmod a+rw /var/run/docker.sock'",
    ]
  }
}

resource "null_resource" "setup_jenkins" {
  depends_on = ["aws_instance.ci"]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = "${aws_instance.ci.public_ip}"
      private_key = "${module.key_pair.private_key}"
    }

    inline = [
      "export DOMAIN=${var.domain}",
      "export HTTPS_PORT=${var.https_port}",
      "export CF_KEY=${var.cf_key}",
      "export CF_EMAIL=${var.cf_email}",

      "${var.start_jenkins}",
      "export SERVICE_ADDR=${var.jenkins_service_ip_addr}",

      "${var.issue_ssl_certificate}",

      "${var.generate_nginx_config_file}",

      "${var.start_nginx_server}"
    ]
  }
}

locals {
  cidr_block = "10.255.0.0/16"
}

data "aws_availability_zones" "available" {}
