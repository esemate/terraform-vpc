data "aws_route53_zone" "etsfactorycom" {
  name         = "etsfactory.com."
  private_zone = false
}

resource "aws_route53_record" "potter" {
  zone_id = data.aws_route53_zone.etsfactorycom.zone_id
  name    = "potter.${data.aws_route53_zone.etsfactorycom.name}"
  type    = "A"
  ttl     = "300"
  records = ["212.230.124.198"]
}

resource "aws_route53_record" "test" {
  zone_id = data.aws_route53_zone.etsfactorycom.zone_id
  name    = "test.${data.aws_route53_zone.etsfactorycom.name}"
  type    = "A"

  alias {        
    name = aws_lb.terraform-lb.dns_name
    zone_id = aws_lb.terraform-lb.zone_id
    evaluate_target_health = true
  }
}