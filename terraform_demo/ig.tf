
resource "aws_internet_gateway" "Daniel_ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-daniel-tf", var.tagging)
  }
}
