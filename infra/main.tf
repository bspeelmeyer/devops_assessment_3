variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}


resource "aws_security_group" "db" {
  description = "Allow traffic"
  vpc_id      = var.vpc_id
  name        = format("%s-%s-sg", var.name, var.environment)

  ingress {
    description = "MongoDB Port from vpc"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow MongoDB Port"
  }
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "${var.name}-${var.environment}-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier              = "${var.name}-${var.environment}-docdb-cluster"
  engine                          = "docdb"
  master_username                 = var.username
  master_password                 = var.password
  backup_retention_period         = 5
  port                            = 27017
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  vpc_security_group_ids          = [aws_security_group.db.id]
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = "tls-disable"
}
