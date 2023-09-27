resource "aws_ssm_parameter" "app_alb_listener_arn" {
  name  = "/${var.project_name}/${var.env}/app_alb_listener_arn" #parameter name
  type  = "String"
  value = aws_lb_listener.http.arn
}