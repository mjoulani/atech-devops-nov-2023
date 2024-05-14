# # tf/main.tf

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">=5.0"
#     }
#   }

#     required_version = ">= 1.7.0"
# }
# #hello 
# provider "aws" {
#   region  = var.zone
# }



# variable "zone" {
#   description = "Zone choice"
# }

# provider "null" {}

# resource "null_resource" "output_zone" {
#   provisioner "local-exec" {
#     command = "echo ${var.zone}"
#   }
# }

# output "tf_var_zone_output" {
#   value = var.zone
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
  
  backend "s3" {
    bucket         = "muh-tfstate-bucket"  # Corrected bucket name
    key            = "state/terraform.tfstate"
    region         = "us-west-1"
    #encrypt        = false
    dynamodb_table = "tfstate_tf_lockid"
  }
}

provider "aws" {
  region                   = us-west-1
  shared_credentials_files = ["C:\\Users\\muham.DESKTOP-T5LGP3O\\.aws\\credentials"]
}

resource "aws_s3_bucket" "example" {
  bucket = "muh-tfstate-bucket"  # Corrected bucket name

  tags = {
    Name        = "My bucket"
    Environment = "terraform state file"
  }
}





