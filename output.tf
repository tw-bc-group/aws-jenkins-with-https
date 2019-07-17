output "jenkins_public_ip" {
  value = "${aws_instance.ci.public_ip}"
}