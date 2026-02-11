#creating vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "created-vpc"
  }
}
#creating public subnet
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24" 
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

    tags = {
        Name = "Public-1"
    }
}
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-2"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "created-igw"
  }
}
# creating route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
#creating route table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt.id
}

#creating prestashop instance security group
resource "aws_security_group" "ec2_sg" {
  name   = "prestashop-ec2-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#creating Rdatabase security group
resource "aws_security_group" "db_sg" {
  name   = "prestashop-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#RDS subnet 
resource "aws_db_subnet_group" "db_subnet" {
  name       = "prestashop-db-subnet"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

#creating RDS instance
resource "aws_db_instance" "prestashop_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible  = false
  skip_final_snapshot  = true
}
#creating Prestashop EC2 instance
resource "aws_instance" "prestashop-server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/scripts.sh", {
    db_host     = aws_db_instance.prestashop_db.address
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  })

  tags = {
    Name = "prestashop-server"
  }
}
