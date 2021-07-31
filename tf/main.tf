## Data resources
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

data "template_file" "init" {
  template = file("${path.module}/files/init.tpl")
  vars = {
    postgresql_host            = aws_db_instance.default.address
    postgresql_database        = aws_db_instance.default.name
    postgresql_username        = aws_db_instance.default.username
    postgresql_password        = random_password.aws_db_password.result
    postgresql_init_script_url = var.sql_initial_script_url
  }
}

## AWS VPC resources
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "Main VPC"
  })
}

resource "aws_internet_gateway" "public_gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "Main Internet Gateway"
  })
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"

  tags = merge(var.tags, {
    Name = "Public Subnet A"
  })
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gw.id
  }

  tags = merge(var.tags, {
    Name = "Public Subnet route table"
  })
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true
  tags = merge(var.tags, {
    Name = "NAT Gateway elastic IP"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(var.tags, {
    Name = "NAT gateway"
  })
}

resource "aws_subnet" "nated_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = merge(var.tags, {
    Name = "NAT-ed A Subnet"
  })
}

resource "aws_subnet" "nated_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = merge(var.tags, {
    Name = "NAT-ed B Subnet"
  })
}

resource "aws_route_table" "nated" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(var.tags, {
    Name = "NAT-ed subnet route table"
  })
}

resource "aws_route_table_association" "nated_a" {
  subnet_id      = aws_subnet.nated_a.id
  route_table_id = aws_route_table.nated.id
}

resource "aws_route_table_association" "nated_b" {
  subnet_id      = aws_subnet.nated_b.id
  route_table_id = aws_route_table.nated.id
}

## AWS EC2 instance
resource "aws_network_interface" "web" {
  subnet_id   = aws_subnet.public_a.id
  private_ips = ["10.0.1.10"]

  security_groups = [aws_security_group.web.id]

  tags = merge(var.tags, {
    Name = "Web1 Network Interface"
  })
}

resource "aws_security_group" "web" {
  name   = "web-servers-sg"
  vpc_id = aws_vpc.main.id

  // http access
  ingress {
    description = "Allow http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  // ssh access
  ingress {
    description = "Allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  // Terraform removes the default rule
  egress {
    description = "Allow outsite traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.ec2_key_name

  network_interface {
    network_interface_id = aws_network_interface.web.id
    device_index         = 0
  }

  user_data = data.template_file.init.rendered

  tags = merge(var.tags, {
    Name = "A Cloud Guru App Server"
  })
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  vpc      = true
}

## AWS RDS
resource "aws_db_subnet_group" "default" {
  name       = "postgres_subnets"
  subnet_ids = [aws_subnet.nated_a.id, aws_subnet.nated_b.id]

  tags = merge(var.tags, {
    Name = "Postgres rds db subnet group"
  })
}

resource "aws_security_group" "rds" {
  name   = "postgres_rds_sg"
  vpc_id = aws_vpc.main.id

  # Only postgres in
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "postgres_rds_sg"
  })
}

resource "aws_db_parameter_group" "default" {
  name   = "postgres12"
  family = "postgres12"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = merge(var.tags, {
    Name = "postgres12-params"
  })
}

resource "random_password" "aws_db_password" {
  length           = 16
  special          = true
  override_special = "/@,"
}

resource "aws_db_instance" "default" {
  identifier             = var.rds_instance_identifier
  instance_class         = "db.t2.micro"
  multi_az               = false
  allocated_storage      = 5
  max_allocated_storage  = 20
  engine                 = "postgres"
  engine_version         = "12.6"
  name                   = var.rds_instance_db_name
  username               = var.rds_instance_db_username
  password               = random_password.aws_db_password.result
  port                   = 5432
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.default.name
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = merge(var.tags, {
    Name = "postgres-gurudb"
  })
}