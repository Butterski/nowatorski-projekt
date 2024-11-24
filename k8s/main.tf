terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Deployment
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          image = "nowatorski-backend:latest"
          name  = "backend"
          image_pull_policy = "Never"  # Dodajemy tę linię

          port {
            container_port = 8000
          }
        }
      }
    }
  }
}
# Service
resource "kubernetes_service" "backend" {
  metadata {
    name = "backend-service"
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      port        = 80
      target_port = 8000
    }

    type = "ClusterIP"
  }
}

# Ingress
resource "kubernetes_ingress_v1" "backend" {
  metadata {
    name = "backend-ingress"
  }

  spec {
    rule {
      http {
        path {
          path = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = "backend-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}