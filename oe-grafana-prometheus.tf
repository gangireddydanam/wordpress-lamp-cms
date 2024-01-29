# Observability implemenation : 
# metrics/trace:
# grafana ---sg
# prometheus --sg


# logging :
# elasticsearch--sg
# kibana --sg

# one load balancer --sg
# logging-internal.temperature.ai---alb(rules)----tg---kibana ------ES-------------filebeat/apache
# metrics-internal.temperature.ai---alb(rules)-----tg---grafana ------prometheus-----node exporter/apache


# metrics/trace:
# grafana ---sg--3000
# prometheus --sg--9090

#binary installation 
#download zip/tar/tgz --extract / permission / start 

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

#security group for grafana
resource "aws_security_group" "grafana" {
  vpc_id      = aws_vpc.own_vpc.id
  name        = "grafana"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # ingress = [  ]
  # egress = [  ]
  tags = {
    Name = "grafana"
  }
}

resource "aws_vpc_security_group_ingress_rule" "grafana_ssh" {
  security_group_id            = aws_security_group.grafana.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "grafana_bastion" {
  security_group_id            = aws_security_group.grafana.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
  referenced_security_group_id = aws_security_group.bastion.id
}


resource "aws_vpc_security_group_ingress_rule" "grafana_http" {
  security_group_id = aws_security_group.grafana.id
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
#   cidr_ipv4         = "0.0.0.0/0"
referenced_security_group_id = aws_security_group.oe_lb.id 
}



resource "aws_vpc_security_group_egress_rule" "grafana_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.grafana.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "grafana_allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.grafana.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#create ec2 for grafana
resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.grafana.id]
  subnet_id              = aws_subnet.app[1].id
  #   user_data = file("scripts/grafana_userdata.sh")


  tags = {
    Name      = "stage-grafana"
    Team      = "Devops"
    Manual    = "false"
    Terraform = "true"
  }
}



#security group for prometheus
resource "aws_security_group" "prometheus" {
  vpc_id      = aws_vpc.own_vpc.id
  name        = "prometheus"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # ingress = [  ]
  # egress = [  ]
  tags = {
    Name = "prometheus"
  }
}

resource "aws_vpc_security_group_ingress_rule" "prometheus_ssh" {
  security_group_id            = aws_security_group.prometheus.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "prometheus_http" {
  security_group_id = aws_security_group.prometheus.id
  from_port         = 9090
  ip_protocol       = "tcp"
  to_port           = 9090
  #   cidr_ipv4         = "0.0.0.0/0"
  referenced_security_group_id = aws_security_group.grafana.id
}



resource "aws_vpc_security_group_egress_rule" "prometheus_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.prometheus.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "prometheus_allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.prometheus.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#create ec2 for prometheus
resource "aws_instance" "prometheus" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.prometheus.id]
  subnet_id              = aws_subnet.app[1].id
  #   user_data = file("scripts/prometheus_userdata.sh")


  tags = {
    Name      = "stage-prometheus"
    Team      = "Devops"
    Manual    = "false"
    Terraform = "true"
  }
}


#load balancer 
#security group 
#target group 
#listener -80----forward-----tg--3000---attach---grafana

resource "aws_security_group" "oe_lb" {
  vpc_id      = aws_vpc.own_vpc.id
  name        = "oe_lb"
  description = "Allow TLS inbound traffic and all outbound traffic"
  # ingress = [  ]
  # egress = [  ]
  tags = {
    Name = "oe_lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "oe_lb_http" {
  security_group_id = aws_security_group.oe_lb.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4         = "${chomp(data.http.myip.body)}/32"
}


resource "aws_lb" "oe_lb" {
  name               = "oe-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.oe_lb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Environment = "wodpress"
  }
}
#target group
resource "aws_lb_target_group" "grafana" {
  name     = "grafana-lb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.own_vpc.id
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = aws_instance.grafana.id
  port             = 3000
}

resource "aws_lb_listener" "grafana_http" {
  load_balancer_arn = aws_lb.oe_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

#host based routing
resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = aws_lb_listener.grafana_http.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = ["metrics-internal.temparatureai.xyz"]
    }
  }
}