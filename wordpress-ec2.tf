#to create ec2 
#ami 
#instance type 
#pem 
#security group (vpc)
#tags 
#zone/subnet 
#userdata

#resources we crate 

#resources already exist 
#region 
#zone 
#ami 

#pem




resource "aws_security_group" "wordpress" {
  vpc_id      = aws_vpc.own_vpc.id
  name        = "wordpress"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # ingress = [  ]
  # egress = [  ]
  tags = {
    Name = "wordpress"
  }
}


resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id = aws_security_group.wordpress.id
  # cidr_ipv4         = aws_security_group.bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "wordpress_http" {
  security_group_id = aws_security_group.wordpress.id
  # cidr_ipv4         = "0.0.0.0/0"
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "wordpress_prometheus" {
  security_group_id = aws_security_group.wordpress.id
  # cidr_ipv4         = "0.0.0.0/0"
  from_port                    = 9100
  ip_protocol                  = "tcp"
  to_port                      = 9100
  referenced_security_group_id = aws_security_group.prometheus.id
}



resource "aws_vpc_security_group_egress_rule" "wordpress_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "wordpress_allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.wordpress.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.amazon.id
  instance_type = "t2.micro"
  # key_name = "simple"
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.wordpress.id]
  subnet_id              = aws_subnet.app[0].id
  user_data              = file("scripts/apache_userdata.sh")
  # aws_subnet.public[*].id

  tags = {
    Name      = "stage-wordpress"
    Team      = "Devops"
    Manual    = "false"
    Terraform = "true"
  }
}



