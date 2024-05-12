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






