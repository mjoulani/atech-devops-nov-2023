# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "public-subnet-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "11.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_a
  tags = {
    Name = var.tagging+"-subnet-1--tf"
  }
}

# Create Private Subnet 1
# terraform aws create subnet
resource "aws_subnet" "private-subnet-1" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "11.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone_a

  tags = {
    Name = var.tagging+"subnet-1-tf"
  }
}
