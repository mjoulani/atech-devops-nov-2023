


resource "aws_instance" "public_instance" {
  subnet_id               = aws_subnet.public_subnet.id
  ami                     = "ami-0c94855ba95c71c99"
  instance_type           = "t2.micro"
  associate_public_ip_address = true

  # Other instance configuration...
}

resource "aws_instance" "private_instance" {
  subnet_id               = aws_subnet.private_subnet.id
  ami                     = "ami-0c94855ba95c71c99"
  instance_type           = "t2.micro"


}

