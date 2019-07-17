variable "key_name" {
  type    = "string"
}

variable "ssh_key_path" {
  type        = "string"
  default     = "./secrets"
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "private_key_extension" {
  type        = "string"
  default     = ".pem"
  description = "Private key extension"
}

variable "public_key_extension" {
  type        = "string"
  default     = ".pub"
  description = "Public key extension"
}

variable "chmod_command" {
  type        = "string"
  default     = "chmod 400 %v"
  description = "Template of the command executed on the private key file"
}