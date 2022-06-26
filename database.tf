resource "aws_db_instance" "default" {
  allocated_storage  = 10
  engine  = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  db_subnet_group_name = "db-subnet"
  db_name = "first-db"
  username = "user"
  password = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
}
