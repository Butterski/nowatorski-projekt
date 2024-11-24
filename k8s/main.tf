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
          image_pull_policy = "Never"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_HOST"
            value = "redis"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
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

# CronJob
resource "kubernetes_cron_job_v1" "cleanup" {
  metadata {
    name = "cleanup-job"
  }
  spec {
    schedule = "0 0 * * *"  # Codziennie o północy
    job_template {
      metadata {
        name = "cleanup-job-template"
      }
      spec {
        template {
          metadata {
            name = "cleanup-job-template"
          }
          spec {
            container {
              name    = "cleanup"
              image   = "nowatorski-backend:latest"
              command = ["python", "cleanup.py"]
              resources {
                limits = {
                  cpu    = "200m"
                  memory = "256Mi"
                }
                requests = {
                  cpu    = "100m"
                  memory = "128Mi"
                }
              }
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

# Redis StatefulSet
resource "kubernetes_stateful_set" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    service_name = "redis"
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:latest"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

# Redis Service
resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    cluster_ip = "None"
  }
}