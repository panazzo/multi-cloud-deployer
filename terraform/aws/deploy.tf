############################################
############## VPC and Network #############
############################################

# VPC
resource "aws_vpc" "vpc_test" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags {
    Name = "vpc_test"
  }
}

# Public subnet zone A
resource "aws_subnet" "subnet_zone_a_test" {
  vpc_id                  = "${aws_vpc.vpc_test.id}"
  cidr_block              = "192.168.0.0/26"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = "true"
  tags {
    Name = "subnet_zone_a_test"
  }
}

# Default Route table
resource "aws_route_table" "public_route_table_test" {
  vpc_id  = "${aws_vpc.vpc_test.id}"
  tags {
    Name = "public_route_table_test"
  }
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway_test" {
  vpc_id = "${aws_vpc.vpc_test.id}"

  tags {
    Name = "nternet_gateway_test"
  }
}

# Route for route table
resource "aws_route" "public_route_test" {
  route_table_id          = "${aws_route_table.public_route_table_test.id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.internet_gateway_test.id}"
}

# Route associations
resource "aws_route_table_association" "route_table_association_zone_a_test" {
  subnet_id      = "${aws_subnet.subnet_zone_a_test.id}"
  route_table_id = "${aws_route_table.public_route_table_test.id}"
}

############################################
###############  Security Group ############
############################################

# Securiy group
resource "aws_security_group" "security_group_test" {
  name        = "services_itsm_security_group"
  description = "security group full access"
  vpc_id      = "${aws_vpc.vpc_test.id}" 

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "security_group_test"
  }
}

############################################
################  Application ##############
############################################

resource "aws_instance" "aws_instance_test" {
  ami           = "ami-4090f22c"
  instance_type = "t2.large"

  vpc_security_group_ids = ["${aws_security_group.security_group_test.id}"]

  subnet_id = "${aws_subnet.subnet_zone_a_test.id}"
  key_name  = "key-pair-test"

  user_data = "${file("install.txt")}"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 100
    delete_on_termination = true
  }

  tags {
    Name = "aws_instance_test"
  }
}

resource "aws_eip" "elastic_ip_test" {
  instance = "${aws_instance.aws_instance_test.id}"
  vpc      = true
}

############################################
#################### DNS ###################
############################################

data "aws_route53_zone" "services_public_zone" {
  name = "cloud104.io."
}

resource "aws_route53_record" "aws_route53_record_test" {
  zone_id = "${data.aws_route53_zone.services_public_zone.zone_id}"
  name    = "multi-cloud"
  type    = "A"
  ttl     = "30"
  records = ["${aws_eip.elastic_ip_test.public_ip}"]
}
