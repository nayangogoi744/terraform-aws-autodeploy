variable "region"{
  description = "Value of the region"
  type        = string
  default     = "ap-south-1"
}

variable "ami"{
  description = "Value of the ami"
  type        = string
  default     = "ami-0c1a7f89451184c8b"
}

variable "instance_type"{
  description = "Value of the instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ProdAppServerInstance"
}
variable "access_key" {
  description = "Value of the access key"
  type        = string
  default     = "<access-key>"
}
variable "secret_key" {
  description = "Value of the secret key"
  type        = string
  default     = "<secret-key>"
}

variable "vpc_cidr" {
  description = "Value of cidr for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Value of cidr for subnet"
  type        = string
  default     = "10.0.1.0/24"
}