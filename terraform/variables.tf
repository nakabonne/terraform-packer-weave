variable "aws_region" {
  type        = string
  description = "aws region"
  default     = "ap-northeast-1"
}

variable "availability_zones" {
  description = "The availability zones into which the EC2 Instances should be deployed."
  type        = list(string)
  default     = ["ap-northeast-1d"]
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
  default     = "weave"
}

variable "instance_type" {
  type        = string
  description = "instance type"
  default     = "t2.small"
}

variable "ami_id" {
  type        = string
  description = "ID of machine image that has installed weave and docker"
}

variable "cluster_size" {
  description = "The number of nodes to have in the Consul cluster. We strongly recommended that you use either 3 or 5."
  type        = number
  default     = 2
}
