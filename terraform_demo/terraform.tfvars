# Rename or copy this file to terraform.tfvars
# Prefix must be all lowercase letters, digits, and hyphens.
# Make sure it is at least 5 characters long.

region              = "ap-northeast-1"
cidr_block_vpc      = "10.0.0.0/16"
route_table         = "0.0.0.0/0"
availability_zone_a = "ap-northeast-1a"
availability_zone_b = "ap-northeast-1c"
tagging             = "daniel-tf-demo2"
key_name            = "Daniel-key"