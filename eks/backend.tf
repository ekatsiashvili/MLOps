#terraform {
#  backend "s3" {
#    bucket = "terraform-state-bucket-goit-olena-final-v4"
    
#    key    = "eks-cluster-prod/terraform.tfstate"
    
#    region = "us-east-1"
    
#    dynamodb_table = "terraform-locks-goit"
    
#    encrypt = true
#  }
#}