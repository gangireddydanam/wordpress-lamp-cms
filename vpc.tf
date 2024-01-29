#zones
data "aws_availability_zones" "available" {
  state = "available"
}

#create vpc
resource "aws_vpc" "own_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

#subnets 
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.own_vpc.id
  cidr_block              = element(var.pub_subnet_cidr, count.index)

  tags = {
    Name = var.pub_subnet
  }
  depends_on = [aws_subnet.app]
}

#app-subnets
resource "aws_subnet" "app" {
  count             = length(data.aws_availability_zones.available.names)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id            = aws_vpc.own_vpc.id
  cidr_block        = element(var.app_subnet_cidr, count.index)

  tags = {
    Name = var.app_subnet
  }
}

#data-subnets
resource "aws_subnet" "data" {
  count             = length(data.aws_availability_zones.available.names)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id            = aws_vpc.own_vpc.id
  cidr_block        = element(var.data_subnet_cidr, count.index)

  tags = {
    Name = var.data_subnet
  }
}


#igw 

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.own_vpc.id

  tags = {
    Name = var.vpc_name
  }
}

#nat-gw /eip 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = var.vpc_name
  }

  depends_on = [aws_internet_gateway.gw, aws_eip.eip]
}
#eip
resource "aws_eip" "eip" {
  tags = {
    Name = var.vpc_name
  }
}
#routetable 
resource "aws_route_table" "puiblic" {
  vpc_id = aws_vpc.own_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.own_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.vpc_name
  }
}

#association 
resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.puiblic.id
}

resource "aws_route_table_association" "app" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.private.id
}