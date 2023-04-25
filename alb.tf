# make load balancer resource named "fluentbit_dev_alb"
resource "aws_lb" "fluentbit_dev_alb" {
  name               = "fluentbit-dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.fluentbit_dev_external_sg.id]
  subnets            = [aws_subnet.fluentbit_dev_subnet_1.id, aws_subnet.fluentbit_dev_subnet_2.id]
  tags = {
    Name = "fluentbit_dev_alb"
  }
}

# make target group resource named "fluentbit_dev_target_group" avaiable in awsvpc
resource "aws_lb_target_group" "fluentbit_dev_target_group" {
  name        = "fluentbit-dev-target-group"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fluentbit_dev.id
  target_type = "ip"
  tags = {
    Name = "fluentbit_dev_target_group"
  }
}

# make listener resource named "fluentbit_dev_listener"
resource "aws_lb_listener" "fluentbit_dev_listener" {
  load_balancer_arn = aws_lb.fluentbit_dev_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.fluentbit_dev_target_group.arn
    type             = "forward"
  }
}
