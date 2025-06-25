resource "aws_service_discovery_private_dns_namespace" "cc_backend_service_namespace" {
  name        = "cc-backend-namespace"
  description = "Private DNS namespace for CareConnect backend services"
  vpc         = var.vpc_id
  tags        = merge(var.default_tags, { Name : "cc-backend-service-namespace" })
}

resource "aws_service_discovery_service" "cloudmap_billing_service" {
  name = "cc-billing-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cc_backend_service_namespace.id

    dns_records {
      type = "A"
      ttl  = 10
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 3
  }
  tags = merge(var.default_tags, { Name : "cc-billing-service" })
}