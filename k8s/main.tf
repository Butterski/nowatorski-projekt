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