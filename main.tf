#Define the main attributes to be used by the deployment
#owner: Alexandre Cezar

#Sets the required providers and versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }
}

# Defines the region where all the region based resources are going to be created
provider "aws" {
  region = var.region
}
