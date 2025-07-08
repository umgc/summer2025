resource "aws_service_discovery_private_dns_namespace" "cc_backend_service_namespace" {
  name        = "cc-backend-namespace"
  description = "Private DNS namespace for CareConnect backend services"
  vpc         = var.vpc_id
  tags        = merge(var.default_tags, { Name : "cc-backend-service-namespace" })
}

resource "aws_service_discovery_service" "cloudmap_core_service" {
  name = "cc-core-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cc_backend_service_namespace.id

    dns_records {
      type = "A"
      ttl  = 10 # 10 seconds
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
  tags = merge(var.default_tags, { Name : "cc-core-service" })
}