resource "aws_db_instance" "Master_db" {
  allocated_storage    = 10
  identifier           = var.identifier
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.name
  username             = var.user
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = true
}