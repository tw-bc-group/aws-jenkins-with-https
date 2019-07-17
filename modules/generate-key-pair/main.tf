locals {
  public_key_filename  = "${format("%s/%s%s", var.ssh_key_path, var.key_name, var.public_key_extension)}"
  private_key_filename = "${format("%s/%s%s", var.ssh_key_path, var.key_name, var.private_key_extension)}"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  depends_on = ["tls_private_key.private_key"]
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.private_key.public_key_openssh}"
}

resource "local_file" "public_key_openssh" {
  content    = "${tls_private_key.private_key.public_key_openssh}"
  filename   = "${local.public_key_filename}"
}

resource "local_file" "private_key_pem" {
  content    = "${tls_private_key.private_key.private_key_pem}"
  filename   = "${local.private_key_filename}"
}

resource "null_resource" "chmod" {
  depends_on = ["local_file.private_key_pem"]
  triggers = {
    local_file_private_key_pem = "local_file.private_key_pem"
  }

  provisioner "local-exec" {
    command = "${format(var.chmod_command, local.private_key_filename)}"
  }
}