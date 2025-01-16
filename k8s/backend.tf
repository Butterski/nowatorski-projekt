# Backend Deployment
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend-deployment"
    namespace = kubernetes_namespace.backend.metadata[0].name
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
          image             = var.backend_image
          name              = "backend"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
          }

          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis_secret.metadata[0].name
                key  = "redis_password"
              }
            }
          }

          env {
            name  = "REDIS_HOST"
            value = "redis.${kubernetes_namespace.redis.metadata[0].name}.svc.cluster.local"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
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

# Backend Service
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.backend.metadata[0].name
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

# Backend Ingress
resource "kubernetes_ingress_v1" "backend" {
  metadata {
    name      = "backend-ingress"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  spec {
    rule {
      http {
        path {
          path      = "/api"
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

# Cleanup CronJob
resource "kubernetes_cron_job_v1" "cleanup" {
  metadata {
    name      = "cleanup-job"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }
  spec {
    schedule = "0 0 * * *"
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
              image   = var.backend_image
              command = ["python", "cleanup.py"]

              env {
                name = "REDIS_PASSWORD"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.redis_secret.metadata[0].name
                    key  = "redis_password"
                  }
                }
              }

              env {
                name  = "REDIS_HOST"
                value = "redis.${kubernetes_namespace.redis.metadata[0].name}.svc.cluster.local"
              }

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