#1.vpc

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    #Name = "ecostream-vpc"
    Name = "ecostream-${local.environment}-vpc"
    managed_by = "terraform"
  }
}

#2.public_subnets

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    #Name = "ecostream-vpc-public_az1"
    Name       = "ecostream-${local.environment}-public-az1"
    managed_by = "terraform"
  }


}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name       = "ecostream-${local.environment}-public-az2"
    #Name = "ecostream-vpc-public_az2"
    managed_by = "terraform"
  }


}

#3.private_subnet (app)
resource "aws_subnet" "private_app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name       = "ecostream-${local.environment}-private-app-az1"
    #Name = "ecostream-vpc-private_app_az1"
    managed_by = "terraform"
  }


}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name       = "ecostream-${local.environment}-private-app-az2"
    #Name = "ecostream-vpc-private_app_az2"
    managed_by = "terraform"
  }
}

#3.a private_subnet (db)

resource "aws_subnet" "private_db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name       = "ecostream-${local.environment}-private-db-az1"
    #Name = "ecostream-vpc-private_db_az1"
    managed_by = "terraform"
  }
}

resource "aws_subnet" "private_db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name       = "ecostream-${local.environment}-private-db-az2"
    #Name = "ecostream-vpc-private_db_az2"
    managed_by = "terraform"
  }
}

#4.internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name       = "ecostream-${local.environment}-igw"
    #Name = "ecostream-vpc-igw"
    managed_by = "terraform"
  }
}

#5. public route table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name       = "ecostream-${local.environment}-public-rt"
    #Name = "ecostream-vpc-public_rt"
    managed_by = "terraform"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id
}

#6.NAT_gateway 
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name       = "ecostream-${local.environment}-nat-eip"
    #Name = "ecostream-vpc-nat"
    managed_by = "terraform"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name       = "ecostream-${local.environment}-nat"
    managed_by = "terraform"
  }

}

# 7. Private Route Table - DB
resource "aws_route_table" "private_db_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name       = "ecostream-private-db-rt"
    managed_by = "terraform"
  }
}

# Associate DB Subnet AZ1
resource "aws_route_table_association" "private_db_az1_assoc" {
  subnet_id      = aws_subnet.private_db_az1.id
  route_table_id = aws_route_table.private_db_rt.id
}

# Associate DB Subnet AZ2
resource "aws_route_table_association" "private_db_az2_assoc" {
  subnet_id      = aws_subnet.private_db_az2.id
  route_table_id = aws_route_table.private_db_rt.id
}


#8.  Private Route Table - APP

resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name       = "ecostream-private-app-rt"
    managed_by = "terraform"
  }
}

# Default route to NAT Gateway
resource "aws_route" "private_app_internet_route" {
  route_table_id         = aws_route_table.private_app_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate App Subnet AZ1
resource "aws_route_table_association" "private_app_az1_assoc" {
  subnet_id      = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private_app_rt.id
}

# Associate App Subnet AZ2
resource "aws_route_table_association" "private_app_az2_assoc" {
  subnet_id      = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private_app_rt.id
}

# ----------------------------------
# ALB Security Group
# ----------------------------------
resource "aws_security_group" "alb_sg" {
  name   = "ecostream-${local.environment}-alb-sg"
  #name        = "ecostream-alb-sg"
  description = "Allow HTTP from Internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "ecostream-alb-sg"
    managed_by = "terraform"
  }
}

# ----------------------------------
# App Security Group
# ----------------------------------
resource "aws_security_group" "app_sg" {
  name   = "ecostream-${local.environment}-app-sg"
  #name        = "ecostream-app-sg"
  description = "Allow HTTP from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Optional: Allow SSH via SSM or Bastion if needed
  # DO NOT open SSH to internet

  egress {
    description = "Allow outbound traffic to NAT/Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "ecostream-app-sg"
    managed_by = "terraform"
  }
}

# ----------------------------------
# DB Security Group
# ----------------------------------
resource "aws_security_group" "db_sg" {
  name   = "ecostream-${local.environment}-db-sg"
  #name        = "ecostream-db-sg"
  description = "Allow MySQL from App tier only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "Allow outbound traffic inside VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "ecostream-db-sg"
    managed_by = "terraform"
  }
}


#11. launch template 

resource "aws_launch_template" "app" {
  name_prefix   = "ecostream-${local.environment}-app-"
  #name_prefix   = "ecostream-app"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "EcoStream Secure ${local.environment} Environment Running" > /var/www/html/index.html
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecostream-app-instance"
    }
  }
}

# ----------------------------------
# Target Group
# ----------------------------------
resource "aws_lb_target_group" "tg" {
  name     = "ecostream-${local.environment}-tg"
  #name     = "ecostream-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name       = "ecostream-tg"
    managed_by = "terraform"
  }
}

# ----------------------------------
# Application Load Balancer
# ----------------------------------
resource "aws_lb" "alb" {
  name               = "ecostream-${local.environment}-alb"
  #name               = "ecostream-alb"
  load_balancer_type = "application"
  internal           = false   # internet-facing

  subnets = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]

  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name       = "ecostream-alb"
    managed_by = "terraform"
  }
}

# ----------------------------------
# Listener
# ----------------------------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [
    aws_subnet.private_app_az1.id,
    aws_subnet.private_app_az2.id
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type = "ELB"

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 60
    }
  }


  tag {
    key                 = "Name"
    value               = "ecostream-app"
    propagate_at_launch = true
  }
}

#DB Subnet Group (Private DB Subnets Only)

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "ecostream-${local.environment}-db-subnet-group"
  #name = "ecostream-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_az1.id,
    aws_subnet.private_db_az2.id
  ]

  tags = {
    Name       = "ecostream-db-subnet-group"
    managed_by = "terraform"
  }
}

# Production-Ready RDS Multi-AZ

resource "aws_db_instance" "db" {
  identifier            = "ecostream-${local.environment}-db"
  #identifier              = "ecostream-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"

  username = var.db_username
  password = var.db_password

  #multi_az               = true
  multi_az            = local.environment == "prod" ? true : false
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # 🔐 Security Best Practices
  storage_encrypted      = true
  deletion_protection = local.environment == "prod" ? true : false
  #deletion_protection    = true

  # 💾 Backup Configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  #skip_final_snapshot = false
  skip_final_snapshot = local.environment == "prod" ? false : true


  tags = {
    Name       = "ecostream-rds"
    managed_by = "terraform"
  }
}


