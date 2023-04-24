resource "aws_lb" "pcfw-lb" {
  name               = "pcfw-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.private-subnet.id,
    aws_subnet.private2-subnet.id
  ]
}

resource "aws_lb_target_group" "pcfwtg" {
  name_prefix = "pcfwtg"
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

resource "aws_lb_listener" "pcfwlistener" {
  load_balancer_arn = aws_lb.pcfw-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pcfwtg.arn
  }
}

resource "aws_launch_configuration" "pcfwlc" {
  name_prefix   = "pcfwlc"
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
  launch_configuration = aws_launch_configuration.pcfwlc.id
  target_group_arns     = [aws_lb_target_group.pcfwtg.arn]
  availability_zones   = ["us-west-2a", "us-west-2c"]

  lifecycle {
    create_before_destroy = true
  }
}
