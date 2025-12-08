resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "infra-tools"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.0" 
  namespace  = kubernetes_namespace.argocd.metadata[0].name

   depends_on = [kubernetes_namespace.argocd]

   values = [
    file("${path.module}/values/argocd-values.yaml")
  ]
}