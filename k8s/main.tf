terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}


# will not work on windows!
# provider "minikube" {
#   kubernetes_version = "v1.31.1"
# }

# resource "minikube_cluster" "docker" {
#   driver       = "docker"
#   cluster_name = "npi-cluster"
#   cni          = "bridge"
#   addons = [
#     "default-storageclass",
#     "storage-provisioner",
#     "ingress",
#     "ingress-dns",
#     "dashboard"
#   ]
# }

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespaces
resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend"
  }
}

resource "kubernetes_namespace" "frontend" {
  metadata {
    name = "frontend"
  }
}

resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

variable "backend_image" {
  description = "Backend image"
  default     = "nowatorski-backend:latest"
}

variable "frontend_image" {
  description = "Frontend image"
  default     = "nowatorski-frontend:latest"
}

resource "null_resource" "start_minikube" {
  provisioner "local-exec" {
    command = "minikube start"
  }
}
