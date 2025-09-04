# ---------------- Target Group ----------------
resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.youtube_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Attach private-instance-1 to TG
resource "aws_lb_target_group_attachment" "nginx_attach" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.private_instance_1.id   # private-instance-1 ID 
  port             = 80
}

# ---------------- Load Balancer ----------------
resource "aws_lb" "nginx_alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main_sg.id] # ensure this SG allows inbound 80 from 0.0.0.0/0
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = {
    Name = "nginx-alb"
  }
}

# ---------------- Listener ----------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

# ---------------- Extra Rule (Optional) ----------------
# Example: match path /nginx and forward to target group
resource "aws_lb_listener_rule" "nginx_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/nginx*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}



