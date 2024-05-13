# tf/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }

    required_version = ">= 1.7.0"
}

provider "aws" {
  region  = var.zone
}
  
  





variable "zone" {
  description = "Zone choice"
}

provider "null" {}

resource "null_resource" "output_zone" {
  provisioner "local-exec" {
    command = "echo ${var.zone}"
  }
}

output "tf_var_zone_output" {
  value = var.zone
}






