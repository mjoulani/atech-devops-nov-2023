resource "aws_instance" "ubuntu_public_linux" {
  ami                         = "ami-0a1ee2fb28fe05df3" 
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.alexey-secure-group.id]
  subnet_id                   = aws_subnet.public-subnet-1a.id
  associate_public_ip_address = true
  key_name                    = "alexeymihaylov_key"
  user_data                   = file("script.sh")
#  depends_on                  = [aws_vpc.vpc, aws_autoscaling_group.Polybot-aws_autoscaling_group]
  tags = {
    Name        = "${var.tagging}-tf"
    environment = "tf"
  }
}


resource "aws_instance" "private_instance" {
  subnet_id               = aws_subnet.private_subnet.id
  ami                     = "ami-0c94855ba95c71c99"
  instance_type           = "t2.micro"


}