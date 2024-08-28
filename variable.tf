variable "region" {   
     description = "The AWS region to create the instance in"
     type        = string
}

variable "ami_ids" {
  description = "A map of AMI IDs by region"
  type        = string
 # default = {
 #  "us-west-1" = "ami-066784287e358dad1"
 #  "us-east-1" = "ami-0abcdef1234567890"
 #  "eu-central-1" = "ami-0abcd1234efgh5678"
 #}
}
