# Deployment key is implemented by the child module.
module "zic_deployment_cmk" {
  source = "../../components/terraform/zic-deployment-cmk"
  deployment_account_id  = data.aws_caller_identity.current.account_id
  zic_role_arn           = data.aws_iam_role.zic.arn
  key_description        = "CMK for Zerto In-Cloud deployment account operations"
  key_alias              = "alias/zerto-zic-deployment"
  key_administrator_arns = []
  key_user_arns          = []
  grant_account_ids      = []
  tags                   = { Service = "zerto", Component = "zic-integration", ManagedBy = "terraform" }
}
