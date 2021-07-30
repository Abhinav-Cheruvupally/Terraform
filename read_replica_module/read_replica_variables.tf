variable "name" {
    type = string
}

variable "env" {
    type = string
}

variable "replicate_db_source" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "kms_key_id" {
  type = string
}
variable "deletion_protection" {
  type=bool
}

variable "vpc_security_group_ids" {
    type = list
  
}