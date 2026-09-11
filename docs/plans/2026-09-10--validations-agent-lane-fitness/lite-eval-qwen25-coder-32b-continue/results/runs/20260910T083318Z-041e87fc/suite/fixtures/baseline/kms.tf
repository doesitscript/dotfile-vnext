# Deployment key is implemented by the child module.
module "zic_deployment_cmk" {
  source = "../../components/terraform/zic-deployment-cmk"
  deployment_account_id  = data.aws_caller_identity.current.account_id
  zic_role_arn           = data.aws_iam_role.zic.arn
  key_description        = local.config.kms.description
  key_alias              = "alias/${local.config.kms.alias_name}"
  key_administrator_arns = local.config.kms.key_administrator_arns
  key_user_arns          = local.config.kms.key_user_arns
  grant_account_ids      = local.config.kms.grant_account_ids
  tags                   = local.config.kms.tags
}
