output "cc_main_lb" {
  value = aws_lb.cc_main_lb
}
output "cc_main_lb_listener_arn" {
  value = aws_lb_listener.http.arn
}