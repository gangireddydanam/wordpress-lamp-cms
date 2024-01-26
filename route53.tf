#hosted zone --NS
#record sets 
#ip address/ load balancer/ cname cloudfront 
#after purchase the domain - we get NS servers(godaddy)---route53 NS

#hosted zone 
resource "aws_route53_zone" "hosted_zone" {
  name = "temparatureai.xyz"
}

#hosted zone map to load balancer- CNAME/A alias --record set
resource "aws_route53_record" "wordpress_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "cms.temparatureai.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

