terraform{
  required_version = ">= 0.12"
}

resource "aws_db_instance" "mydatabase"{
  count = length(var.multidb)
  identifier           = element(var.multidb,count.index) # element(list,index)
  allocated_storage    = 10
  engine               = elemet(var.engine,count.index)
  engine_version       = var.engine_version
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

}