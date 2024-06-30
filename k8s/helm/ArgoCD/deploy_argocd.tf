module "argocd_dev" {
  source             = "./terraform"
  eks_cluster_name   = "Atech"
  chart_version      = "7.3.3"
  
  }

