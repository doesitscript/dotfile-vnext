locals {
  config = {
    kms = {
      alias_name  = "zerto-zic-deployment"
      description = "CMK for Zerto In-Cloud deployment account operations"
      key_administrator_arns = []
      key_user_arns          = []
      grant_account_ids      = []
      tags = { Service = "zerto", Component = "zic-integration", ManagedBy = "terraform" }
    }
  }
}
