variable "access_key" {
  description = "Access key for AWS account"
  type = "string"
}

variable "secret_key" {
  description = "Secret key for AWS account"
  type = "string"
}

variable "region" {
  description = "AWS account using region"
  type = "string"
}

variable "ami" {
  description = "Amazon Machine Image refer to the image of Amazon virtual servers"
  type = "string"
}

variable "instance_type" {
  description = "Instance type of Amazon virtual servers"
  type = "string"
}

# variables for HTTPS setup
variable "domain" {
  description = "Domain name"
  type = "string"
}

variable "cf_key" {
  description = "Cloudflare Global API Key"
  type = "string"
}

variable "cf_email" {
  description = "Cloudflare register email"
  type = "string"
}

variable "https_port" {
  description = "Port that you want to listen for HTTPS"
  type = "string"
}
