# Subnet Group creation
resource "aws_docdb_subnet_group" "main" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(local.tags, { Name = "${local.name_prefix}-subnet-group" })
}

# Security Group creation
resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-sg"
  description = "${local.name_prefix}-sg"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { Name = "${local.name_prefix}-sg" })

  ingress {
    description = "DocumentDB"
    from_port   = "27017"
    to_port     = "27017"
    protocol    = "tcp"
    cidr_blocks = var.docdb_sg_ingress_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Parameter Group creation for database
resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb4.0"
  name        = "${local.name_prefix}-pg"
  description = "${local.name_prefix}-pg"
  tags        = merge(local.tags, { Name = "${local.name_prefix}-pg" })
}

# docdb_cluster creation
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier              = "${local.name_prefix}-cluster"
  engine                          = "docdb"
  master_username                 = data.aws_ssm_parameter.master_username.value
  master_password                 = data.aws_ssm_parameter.master_password.value
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  vpc_security_group_ids          = [aws_security_group.main.id]
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  engine_version                  = var.engine_version
  tags                            = merge(local.tags, { Name = "${local.name_prefix}-cluster" })

}

