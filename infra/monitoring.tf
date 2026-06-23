resource "docker_image" "prometheus" {
  name         = "prom/prometheus:latest"
  keep_locally = true
}

resource "docker_container" "prometheus" {
  name       = "prometheus"
  image      = docker_image.prometheus.image_id
  restart    = "unless-stopped"
  entrypoint = ["/bin/sh", "-c"]
  command = [
    "printf 'global:\\n  scrape_interval: 15s\\n  evaluation_interval: 15s\\nscrape_configs:\\n  - job_name: sentinel-ai\\n    static_configs:\\n      - targets:\\n          - sentiment-staging:8000\\n    metrics_path: /metrics\\n  - job_name: prometheus\\n    static_configs:\\n      - targets:\\n          - localhost:9090\\n' > /etc/prometheus/prometheus.yml && /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.retention.time=15d"
  ]
  networks_advanced {
    name = docker_network.cicd.name
  }
  ports {
    internal = 9090
    external = 9090
  }
}

resource "docker_image" "grafana" {
  name         = "grafana/grafana:latest"
  keep_locally = true
}

resource "docker_container" "grafana" {
  name    = "grafana"
  image   = docker_image.grafana.image_id
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.cicd.name
  }
  ports {
    internal = 3000
    external = 3000
  }
  env = ["GF_SECURITY_ADMIN_PASSWORD=admin"]
}
