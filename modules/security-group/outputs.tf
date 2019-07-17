output "name" {
    value = "${aws_security_group.security_group.name}"
}

output "id" {
    value = "${aws_security_group.security_group.*.id}"
}