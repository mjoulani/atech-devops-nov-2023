provider "null" {}

resource "null_resource" "output_zone" {
  provisioner "local-exec" {
    command = "echo ${var.TF_VAR_zone}"
  }
}

output "tf_var_zone_output" {
  value = var.TF_VAR_zone
}


