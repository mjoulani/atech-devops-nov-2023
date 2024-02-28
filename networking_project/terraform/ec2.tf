


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "aws_instance" "ubuntu_public_linux" {
  ami                        = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.bash-project-secure-group.id]
  subnet_id                   = aws_subnet.public-subnet-1a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name
  tags = {
    Name        =  format("%s-tf", var.tagging)
    environment = "tf"
  }
}


resource "aws_instance" "ubuntu_private_linux" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.bash-project-secure-group.id]
  subnet_id               = aws_subnet.private-subnet-1a.id
  key_name                = aws_key_pair.generated_key.key_name
  tags = {
    Name        =  format("%s-tf", var.tagging)  
    environment = "tf"
  }


}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.private_key_path
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = aws_key_pair.generated_key.key_name
  content  = tls_private_key.private_key.private_key_pem
}