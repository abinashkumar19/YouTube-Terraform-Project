# ---------------- Target Group (5000) ----------------
resource "aws_lb_target_group" "flask_tg" {
  name     = "flask-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.youtube_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "5000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# ---------------- Attach private-instance-2 ----------------
resource "aws_lb_target_group_attachment" "flask_attach" {
  target_group_arn = aws_lb_target_group.flask_tg.arn
  target_id        = aws_instance.private_instance_2.id   # private-instance-2 ID
  port             = 5000
}

# ---------------- Load Balancer ----------------
resource "aws_lb" "flask_alb" {
  name               = "flask-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main_sg.id] # ensure inbound 80 is allowed
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = {
    Name = "flask-alb"
  }
}

# ---------------- Listener (80 -> TG:5000) ----------------
resource "aws_lb_listener" "flask_listener" {
  load_balancer_arn = aws_lb.flask_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_tg.arn
  }
}
