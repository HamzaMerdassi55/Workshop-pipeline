provider "aws" { 
  region = "eu-west-3"
}

resource "aws_instance" "server" {
  ami = "ami-045a8ab02aadf4f88"
  instance_type = "t2.micro"
  key_name = "Workshop"
  vpc_security_group_ids = [aws_security_group.security_groupe.id]
  subnet_id = aws_subnet.workshop-public_subent_01.id
  for_each = toset(["Jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "security_groupe" {
  name = "security_groupe"
  description = "SSH Access"
  vpc_id = aws_vpc.workshop-vpc.id
  ingress {
    description = "SSH access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "workshop-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "workshop-vpc"
  }
}

resource "aws_subnet" "workshop-public_subent_01" {
  vpc_id = aws_vpc.workshop-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-3a"
  tags = {
    Name = "workshop-public_subent_01"
  }
}

resource "aws_subnet" "workshop-public_subent_02" {
  vpc_id = aws_vpc.workshop-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-3b"
  tags = {
    Name = "workshop-public_subent_02"
  }
}

resource "aws_internet_gateway" "workshop-igw" {
  vpc_id = aws_vpc.workshop-vpc.id
  tags = {
    Name = "workshop-igw"
  }
}

resource "aws_route_table" "workshop-public-rt" {
  vpc_id = aws_vpc.workshop-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.workshop-igw.id
  }
  tags = {
    Name = "workshop-public-rt"
  }
}

resource "aws_route_table_association" "workshop-rta-public-subent-01" {
  subnet_id = aws_subnet.workshop-public_subent_01.id
  route_table_id = aws_route_table.workshop-public-rt.id
}

resource "aws_route_table_association" "workshop-rta-public-subent-02" {
  subnet_id = aws_subnet.workshop-public_subent_02.id
  route_table_id = aws_route_table.workshop-public-rt.id
}
