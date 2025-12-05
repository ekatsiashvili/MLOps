module "vpc" {
  source = "./vpc"

  vpc_name = "goit-vpc"
  vpc_cidr = var.vpc_cidr
}

module "eks" {
  source = "./eks"

  cluster_name = var.cluster_name
  
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}