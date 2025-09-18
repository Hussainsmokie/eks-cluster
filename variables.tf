variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "hotstar"
}


variable "node_group_desired_size" {
  default = 3
}

variable "node_group_max_size" {
  default = 3
}

variable "node_group_min_size" {
  default = 3
}

variable "autoscaler_image_tag" {
  default = "v1.29.0"
}

variable "autoscaler_policy_arn" {
  default = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

variable "alb_controller_policy_arn" {
  default = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}
