# Redis StatefulSet
resource "kubernetes_stateful_set" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }

  spec {
    service_name = "redis"
    replicas     = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    update_strategy {
      type = "RollingUpdate"
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

          command = ["redis-server"]
          args = ["--requirepass", "$(REDIS_PASSWORD)"]

          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis_secret_redis_ns.metadata[0].name
                key  = "redis_password"
              }
            }
          }

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
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

          liveness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 15
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "redis-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  wait_for_rollout = true
}

# Redis Service
resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.redis.metadata[0].name
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