resource "aws_launch_template" "foobar" {
  name                   = "Alexey-template"
  image_id               = "ami-0a1ee2fb28fe05df3"
  instance_type          = "t2.micro"
  key_name               = "alexeymihaylov_key"
  vpc_security_group_ids = [aws_security_group.alexey-secure-group.id]
  user_data              = base64encode(data.template_file.test.rendered)

  tags = {
    Name = "alexey-scalling-Terraform"
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "alexey-scalling-Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

data "template_file" "test" {
  template = file("user_data.sh")
}
