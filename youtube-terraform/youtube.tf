provider "aws" {
  region = "us-east-1"
}

# ---------------- VPC ----------------
resource "aws_vpc" "youtube_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "youtube-vpc" }
}

# ---------------- Subnets ----------------
# Public Subnet 1
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.youtube_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "youtube-public-1" }
}

# Public Subnet 2
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.youtube_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "youtube-public-2" }
}

# Private Subnet 1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.youtube_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "youtube-private-1" }
}

# Private Subnet 2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.youtube_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "youtube-private-2" }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.youtube_vpc.id
  tags   = { Name = "youtube-igw" }
}

# ---------------- Elastic IP for NAT ----------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# ---------------- NAT Gateway ----------------
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id
  tags          = { Name = "youtube-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

# ---------------- Route Tables ----------------
# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.youtube_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "youtube-public-rt" }
}

resource "aws_route_table_association" "pub1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.youtube_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = { Name = "youtube-private-rt" }
}

resource "aws_route_table_association" "priv1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}
