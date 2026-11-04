# Le même réseau qu'au Jour 5 (fait à la main dans la console), cette fois décrit en code.

resource "aws_vpc" "labo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "vpc-labo-tf" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.labo.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.zones.names[0]
  map_public_ip_on_launch = true # chaque serveur reçoit une IP publique
  tags                    = { Name = "subnet-public-a-tf" }
}

# La porte du VPC vers Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.labo.id
  tags   = { Name = "igw-labo-tf" }
}

# Le panneau indicateur : « tout ce qui ne va pas dans le VPC → la porte Internet »
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.labo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "rt-public-tf" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
