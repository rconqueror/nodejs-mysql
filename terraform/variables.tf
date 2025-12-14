variable "ami_id" {
  type = string
  description = "AMI for the Instance"
  default = "ami-0ecb62995f68bb549"
}
variable "vpc_id" {
  default = "vpc-0ec5e855010fbcc34"
}
variable "dbname" {
  type = string
  description = "Database name for RDS instance"
}
variable "db_username" {
  type = string
  description = "Username for RDS instance"
}
variable "db_password" {
  type = string
  description = "Password for RDS instance"
}