
resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.tagging+"-igw-tf"
  }
}
