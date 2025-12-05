module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0" 

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    # Група 1: Загальна (CPU)
    general = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"] 
      capacity_type  = "ON_DEMAND"
      
      labels = {
        role = "general"
      }
    }

    # Група 2: "GPU" (Емуляція для завдання, щоб не платити за справжній GPU)
    ml_workload = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.small"]
      
      taints = {
        dedicated = {
          key    = "workload"
          value  = "ml"
          effect = "NO_SCHEDULE"
        }
      }

      labels = {
        role = "ml-gpu-simulated"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}