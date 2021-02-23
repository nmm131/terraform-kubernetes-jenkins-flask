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

resource "kubernetes_namespace" "flask" {
  metadata {
    annotations = {
      name = "flask"
    }
    labels = {
      App = "terraform-kubernetes-jenkins-flask"
    }
    name = "flask"
  }
}

resource "kubernetes_deployment" "flask" {
  metadata {
    namespace = kubernetes_namespace.flask.metadata.0.name
    name = "terraform-kubernetes-jenkins-flask-deployment"
    labels = {
      App = "terraform-kubernetes-jenkins-flask"
    }
  }

  spec {
    replicas = 2 
    selector {
      match_labels = {
        App = "terraform-kubernetes-jenkins-flask"
      }
    }
    template {
      metadata {
        labels = {
          App = "terraform-kubernetes-jenkins-flask"
        }
      }
      spec {
        container {
          image = "nmm131/terraform-kubernetes-jenkins-flask"
          name  = "flask-app"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
  timeouts {
    create = "1m"
    update = "1m"
    delete = "2m"
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    namespace = kubernetes_namespace.flask.metadata.0.name
    name = "terraform-kubernetes-jenkins-flask-svc"
  }
  spec {
    selector = {
      App = kubernetes_deployment.flask.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 5000 
      target_port = 5000
    }

    type = "NodePort"
  }
}
