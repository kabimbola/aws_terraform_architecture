# Creating application load balancer
resource "aws_lb" "alb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.subnet1-pub.id, aws_subnet.subnet2-pub.id]
  tags = {
    Name = "public-lb"
  }
}

#Creating target group
resource "aws_lb_target_group" "alb-tg" {
  name        = "alb-target-group"
  port        = 8080
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = 8080
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "alb-target-group"
  }
}

#Creating load balancer listener
resource "aws_lb_listener" "alb-ls" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

#Attaching instances to alb target group

resource "aws_lb_target_group_attachment" "alb-at" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "alb-at2" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 8080
}

#DNS Configuration

#Get already configured hosted zone from route53

data "aws_route53_zone" "dns" {
  name = var.dns-name
}

#Creating an alias record towards ALB from Route53
resource "aws_route53_record" "dns-record" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = "app.${data.aws_route53_zone.dns.name}"
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
