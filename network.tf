# make vpc resource with cidr block '10.1.0.0/16'
# and enable dns support
resource "aws_vpc" "fluentbit_dev" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "fluentbit_dev"
  }
}

# make public subnet resource on vpc 'fluentbit_dev'
# with cidr block '10.1.1.0/24' on availability zone 'ap-northeast-1a'
resource "aws_subnet" "fluentbit_dev_subnet_1" {
  vpc_id                  = aws_vpc.fluentbit_dev.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

}

# make public subnet resource on vpc 'fluentbit_dev'
# with cidr block '10.1.2.0/24' on availability zone 'ap-northeast-1a'
resource "aws_subnet" "fluentbit_dev_subnet_2" {
  vpc_id                  = aws_vpc.fluentbit_dev.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

}

# make internet gateway resource on vpc 'fluentbit_dev'
resource "aws_internet_gateway" "fluentbit_dev_gateway" {
  vpc_id = aws_vpc.fluentbit_dev.id
}

# make route table on vpc 'fluentbit_dev' and route to internet gateway
resource "aws_route_table" "fluentbit_dev_route_table_1" {
  vpc_id = aws_vpc.fluentbit_dev.id
}

resource "aws_route" "fluentbit_dev_route_1" {
  route_table_id         = aws_route_table.fluentbit_dev_route_table_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fluentbit_dev_gateway.id

}
# make route table on vpc 'fluentbit_dev' and route to internet gateway
resource "aws_route_table" "fluentbit_dev_route_table_2" {
  vpc_id = aws_vpc.fluentbit_dev.id
}

resource "aws_route" "fluentbit_dev_route_2" {
  route_table_id         = aws_route_table.fluentbit_dev_route_table_2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fluentbit_dev_gateway.id
}

# make route table association on subnet 'fluentbit_dev_subnet_1'
# and route table 'fluentbit_dev_route_table'
resource "aws_route_table_association" "fluentbit_dev_subnet_1_association" {
  subnet_id      = aws_subnet.fluentbit_dev_subnet_1.id
  route_table_id = aws_route_table.fluentbit_dev_route_table_1.id
}

# make route table association on subnet 'fluentbit_dev_subnet_2'
# and route table 'fluentbit_dev_route_table'
resource "aws_route_table_association" "fluentbit_dev_subnet_2_association" {
  subnet_id      = aws_subnet.fluentbit_dev_subnet_2.id
  route_table_id = aws_route_table.fluentbit_dev_route_table_2.id
}

# make security group resource on vpc 'fluentbit_dev'
# and allow http and https from anywhere
resource "aws_security_group" "fluentbit_dev_external_sg" {
  name   = "fluentbit_dev_sg"
  vpc_id = aws_vpc.fluentbit_dev.id

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

# make security group resource on vpc 'fluentbit_dev'
# and allow tcp port 8081 from "fluentbit_dev_external_sg"
resource "aws_security_group" "fluentbit_dev_internal_sg" {
  name   = "fluentbit_dev_internal_sg"
  vpc_id = aws_vpc.fluentbit_dev.id

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = ["${aws_security_group.fluentbit_dev_external_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##################
# Workder
##################

# make security group resource on vpc 'fluentbit_dev'
# and allow egress trafic to anywhere 
resource "aws_security_group" "sqs_worker_sg" {
  name   = "sqs_worker_sg"
  vpc_id = aws_vpc.fluentbit_dev.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
