#alb -preq
#security group 
#vpc 
#subnets
#internet/intranet
#targetgroup--attach---wordpress ec2
#listener----forward----targetGroup
#rules 

#security group 
resource "aws_security_group" "alb" {
  vpc_id =     aws_vpc.own_vpc.id
  name        = "alb"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # ingress = [  ]
  # egress = [  ]
  tags = {
    Name = "alb"
  }
}


resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
#   referenced_security_group_id = aws_security_group.bastion.id
}




resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#alb
resource "aws_lb" "alb" {
  name               = "alb-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "wodpress"
  }
}

#targetgroup
resource "aws_lb_target_group" "wordpress" {
  name     = "wordpress-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.own_vpc.id
}

resource "aws_lb_target_group_attachment" "wordpress" {
  target_group_arn = aws_lb_target_group.wordpress.arn
  target_id        = aws_instance.wordpress.id
  port             = 80
}


#listerner rule
resource "aws_lb_listener" "wordpress_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}