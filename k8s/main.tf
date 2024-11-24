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

# Namespaces
resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend"
  }
}

resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

# ConfigMap
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    CLEANUP_DAYS = "30"
    APP_VERSION  = "1.0"
    REDIS_PORT   = "6379"
  }
}

# Secret
resource "kubernetes_secret" "redis_secret" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    redis_password = "bW9qZV90YWpuZV9oYXNsbw==" # base64 encoded "moje_tajne_haslo"
  }
}
resource "kubernetes_secret" "redis_secret_redis_ns" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }

  data = {
    redis_password = "bW9qZV90YWpuZV9oYXNsbw==" # to samo hasło co w poprzednim sekrecie
  }
}

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
          image             = "nowatorski-backend:latest"
          name              = "backend"
          image_pull_policy = "Never"

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
    schedule = "0 0 * * *" # Codziennie o północy
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
