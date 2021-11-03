output "loadbalancer-dns" {
  value = aws_lb.load-balancer.dns_name
}