variable "start_jenkins" {
  type = "string"
  default = "docker run --name jenkins -p 8080:8080 -p 50000:50000 -d jenkins"
}

variable "issue_ssl_certificate" {
  type = "string"
  default = "sh /var/tmp/https-certificate/issue_ssl_certificate.sh $DOMAIN $CF_KEY $CF_EMAIL"
}

variable "jenkins_service_ip_addr" {
  type = "string"
  default = "`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jenkins`:8080"
}

variable "generate_nginx_config_file" {
  type = "string"
  default = "envsubst '$$DOMAIN $$HTTPS_PORT $$SERVICE_ADDR' < /var/tmp/https-certificate/default.conf.template > /var/tmp/https-certificate/default.conf"
}

variable "start_nginx_server" {
  type = "string"
  default = "docker run -p $HTTPS_PORT:$HTTPS_PORT --name nginx -v /var/tmp/https-certificate/:/etc/nginx/conf.d:rw -v /home/ubuntu/.acme.sh:~/.acme.sh:rw -d nginx",
}