provider "docker" {
  # linux
  # host = "unix:///var/run/docker.sock"

  # windows
  host = "npipe:////.//pipe//docker_engine"
  registry_auth {
    address = "registry.hub.docker.com"
  }
}

resource "docker_image" "backend" {
  name = "nowatorski-backend:latest"
  build {
    context    = "${path.root}/../nowatorski_backend"
    dockerfile = "Dockerfile"
    no_cache   = true
  }

  triggers = {
    dockerfile   = filesha256("${path.root}/../nowatorski_backend/Dockerfile")
    main_py      = filesha256("${path.root}/../nowatorski_backend/main.py")
    cleanup_py   = filesha256("${path.root}/../nowatorski_backend/cleanup.py")
    requirements = filesha256("${path.root}/../nowatorski_backend/requirements.txt")
  }
}

resource "docker_image" "frontend" {
  name = "nowatorski-frontend:latest"
  build {
    context    = "${path.root}/../nowatorski_front"
    dockerfile = "Dockerfile"
    no_cache   = true
  }

  triggers = {
    dockerfile   = filesha256("${path.root}/../nowatorski_front/Dockerfile")
    package_json = filesha256("${path.root}/../nowatorski_front/package.json")
    app_js       = filesha256("${path.root}/../nowatorski_front/src/App.js")
  }
}

output "backend_image_id" {
  value = docker_image.backend.id
}

output "frontend_image_id" {
  value = docker_image.frontend.id
}
