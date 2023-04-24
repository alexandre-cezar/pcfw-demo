#Define the variables used by the different terraform files
#owner: Alexandre Cezar

#Controls the deployment region
variable "region" {
  type    = string
  default = "us-west-2"
}
#VPC naming, description and CIDR configuration
variable "vpc" {
  type = map(object({
    name        = string
    description = string
    cidr_block  = string
  }))
  default = {
    pcfw_foundations_vpc = {
      name        = "pcfw-foundations-vpc"
      description = "VPC for the PCFW demo"
      cidr_block  = "172.20.0.0/20"
    }
  }
}

#Public Subnet naming and CIDR configuration
variable "public_subnet" {
  type = object({
    name = string
    cidr_block = string
  })
  default = {
    name = "public-subnet"
    cidr_block = "172.20.1.0/24"
  }
}

#Internal Subnet naming and CIDR configuration
variable "internal_subnet" {
  type = object({
    name = string
    cidr_block = string
  })
  default = {
    name = "internal-subnet"
    cidr_block = "172.20.2.0/24"
  }
}

#Internal Subnet2 naming and CIDR configuration
variable "internal2_subnet" {
  type = object({
    name = string
    cidr_block = string
  })
  default = {
    name = "internal2-subnet"
    cidr_block = "172.20.3.0/24"
  }
}

#AMI ID that is going to be used by the vulnerable instance (region dependent)
variable "vulnerable_ami" {
  type    = string
  default = "ami-0db245b76e5c21ca1" # Ubuntu 20.04 LTS in us-west-2
}

#Instance type that is going to be used by the vulnerable instance
variable "vulnerable_instance_type" {
  type    = string
  default = "c4.large"
}

#AMI ID that is going to be used by the bastion instance (region dependent)
variable "bastion_ami" {
  type    = string
  default = "ami-0db245b76e5c21ca1" # Ubuntu 20.04 LTS in us-west-2
}

#Instance type that is going to be used by the bastion instance
variable "bastion_instance_type" {
  type    = string
  default = "c4.large"
}

#AMI ID that is going to be used by the internal instance (region dependent)
variable "internal_ami" {
  type    = string
  default = "ami-0db245b76e5c21ca1" # Ubuntu 20.04 LTS in us-west-2
}

#Instance type that is going to be used by the internal instance
variable "internal_instance_type" {
  type    = string
  default = "c4.large"
}

#SSH Key that is going to be associated with the instances during deployment
variable "ssh_key_name" {
type    = string
default = "pcfw-ssh"
}

#The path for the SSH key - It has to be locally accessible by the tf plan
variable "ssh_key_path" {
  type    = string
  default = ""
}

#Path to the scripts folder (scripts that automate the configuration of the vulnerable instance)
variable "folder_scripts" {
  type        = string
  description = "The path to the scripts folder"
  default = ""
}