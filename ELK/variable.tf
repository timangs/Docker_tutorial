variable "vpc_id" {
  type = string
  description = "totoro"
}

variable "cidr_blocks" {
  type = string
  description = "10.0.0.0/16"
}

variable "subnets" {
  type = list(string)
  description = "log[1-4]"
}

variable "region" {
  type = string
  description = "seoul"
}

variable "private_route_table_ids" {
  type = list(string)
  description = "private_route_table"
}