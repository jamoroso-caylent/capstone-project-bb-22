resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "docdb-cluster-demo-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier   = "${var.name}-db"
  availability_zones   = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  master_username      = "foo"
  master_password      = "barbut8chars"
  db_subnet_group_name = aws_docdb_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  skip_final_snapshot     = true
}

resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "DB from personal"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = ["179.49.55.246/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_docdb_subnet_group" "default" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
