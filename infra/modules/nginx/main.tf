resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"
  namespace  = kubernetes_namespace.ingress.metadata.0.name
  depends_on = [
    kubernetes_namespace.ingress
  ]
}
