# ##############################################################################
# # Outputs File
# #
# # Here is where we store the output values for all the variables used in our
# # Terraform code. If you create a variable with no default, the user will be
# # prompted to enter it (or define it via config file or command line flags.)
# 
# 
# 
output "vpc" {
  description = "The ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "region" {
  description = "The ID of the region."
  value       = var.region
  
}

output "route_table" {
  description = "The ID of the route table."
  value       = aws_route_table.public-route-table.id
}

output "security_group" {
  description = "The ID of the security group."
  value       = aws_security_group.bash-project-secure-group.id
}

output "ec2" {
  description = "The ID of the ec2."
  value       = aws_instance.ubuntu_public_linux.id
}


output "private_key" {
  description = "The ID of the private_key."
  value       = tls_private_key.private_key.private_key_pem
  sensitive   = true
}

output "private_subnet" {
  description = "The ID of the private_subnet."
  value       = aws_subnet.private-subnet-1a.id
}
output "public_subnet" {
  description = "The ID of the public_subnet."
  value       = aws_subnet.public-subnet-1a.id
  
}
output "private_instance" {
  description = "The ID of the private_instance."
  value       = aws_instance.ubuntu_private_linux.id
}
output "public_instance" {
  description = "The ID of the public_instance."
  value       = aws_instance.ubuntu_public_linux.id
}
output "private_instance_type" {
  description = "The ID of the private_instance_type."
  value       = aws_instance.ubuntu_private_linux.instance_type
  
}

output "private_ip" {
  description = "The ID of the private_ip."
  value       = aws_instance.ubuntu_private_linux.private_ip
}
output "public_ip" {
  description = "The ID of the public_ip."
  value       = aws_instance.ubuntu_public_linux.public_ip
}
# 
# 
# output "private_key_path" {
#   description = "The ID of the private_key_path."
#   value       = aws_key_pair.generated_key.key_name
# }
# Compare this snippet from networking_project/terraform/networking_project.tfvars:
# region = "eu-central-1"
# cidr_block_vpc = "
