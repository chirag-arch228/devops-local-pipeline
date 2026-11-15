terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-finacplus-cluster"
}

resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "devops-prod"
  }
}

resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = "devops-demo-deployment"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "devops-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "devops-demo"
        }
      }

      spec {
        container {
          image             = "devops-demo-app:v1"
          name              = "devops-app"
          image_pull_policy = "Never"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name      = "devops-demo-service"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app_deployment.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
      node_port   = 30080
    }
    type = "NodePort"
  }
}