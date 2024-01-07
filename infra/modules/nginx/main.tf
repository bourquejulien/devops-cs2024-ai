resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.0"
  namespace  = kubernetes_namespace.ingress.metadata.0.name
  depends_on = [
    kubernetes_namespace.ingress
  ]

  set {
    name  = "controller.service.loadBalancerIP"
    value = "${var.static_ip}"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  # set {
  #   name = "controller.service.annotations.service.beta.kubernetes.io/azure-load-balancer-internal"
  #   value = "true"
  # }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = "${var.rg_name}"
  }  
}
