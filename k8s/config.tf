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

# Secret dla backend
resource "kubernetes_secret" "redis_secret" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    redis_password = "bW9qZV90YWpuZV9oYXNsbw=="
  }
}

# Secret dla redis
resource "kubernetes_secret" "redis_secret_redis_ns" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }

  data = {
    redis_password = "bW9qZV90YWpuZV9oYXNsbw=="
  }
}