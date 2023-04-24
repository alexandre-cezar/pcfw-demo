resource "aws_lb" "pcfw-lb" {
  name               = "pcfw-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.private-subnet.id,
    aws_subnet.private2-subnet.id
  ]
}

resource "aws_lb_target_group" "pcfw-tg" {
  name_prefix = "pcfw-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.pcfw-foundations-vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
  }
}

resource "aws_lb_listener" "pcfw-listener" {
  load_balancer_arn = aws_lb.pcfw-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pcfw-tg.arn
  }
}

resource "aws_launch_configuration" "pcfw-lc" {
  name_prefix   = "pcfw-lc"
  image_id      = var.internal_ami
  instance_type = var.internal_instance_type

  security_groups = [aws_security_group.internal_sg.id]

  depends_on = [
    aws_security_group.internal_sg
  ]
}

resource "aws_autoscaling_group" "pcfw-asg" {
  name                 = "pcfw-asg"
  max_size             = 5
  min_size             = 1
  desired_capacity     = 2
  health_check_grace_period = 300
  launch_configuration = aws_launch_configuration.pcfw-lc.id
  target_group_arns     = [aws_lb_target_group.pcfw-tg.arn]
  vpc_zone_identifier   = [aws_subnet.private-subnet.id, aws_subnet.private2-subnet.id]

  lifecycle {
    create_before_destroy = true
  }
}
