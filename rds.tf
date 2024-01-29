#mysql --3306
#who connects to mysql 
#app server --------mysql(sg)
#admin(bastion)--------------mysql(sg)
#security group 
resource "aws_security_group" "mysql_rds" {
  vpc_id      = aws_vpc.own_vpc.id
  name        = "mysql-rds"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # ingress = [  ]
  # egress = [  ]
  tags = {
    Name = "mysql-rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_mysql_rds" {
  security_group_id            = aws_security_group.mysql_rds.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "wordpress_mysql_rds" {
  security_group_id            = aws_security_group.mysql_rds.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.wordpress.id
}



resource "aws_vpc_security_group_egress_rule" "rds_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysql_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "rds_allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.mysql_rds.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#subnetgroup 
resource "aws_db_subnet_group" "rds_subnetgroup" {
  name = "data-subnet-group"
  #   subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]
  subnet_ids = [aws_subnet.data[0].id, aws_subnet.data[1].id, aws_subnet.data[2].id]

  tags = {
    Name = "data-subnet-group"
  }
}

#rds 

resource "aws_db_instance" "default" {
  allocated_storage = 10
  db_name           = "mydb"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  # username             = "rdsadminmysql"
  # password             = "ir0wY41VAdpcou2F5"
  username               = var.username
  password               = "ir0wY41VAdpcou2F5"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.mysql_rds.id]
}
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint

}


#who are all connects with mysql -3306
#admin - from where - bastion 
#applicaiton --rds