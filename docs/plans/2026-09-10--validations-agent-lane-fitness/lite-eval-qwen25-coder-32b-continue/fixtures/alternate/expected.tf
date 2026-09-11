# Deployment key is implemented by the child module.
module "zic_deployment_cmk" {
  source = "../../components/terraform/zic-deployment-cmk"
  deployment_account_id  = local.deployment_account_id
  zic_role_arn           = data.aws_iam_role.zic.arn
  key_description        = "Archive test key; resource text in a string is not a block"
  key_alias              = "alias/archive-sandbox"
  key_administrator_arns = ["arn:aws:iam::555555555555:role/ArchiveMaintainer"]
  key_user_arns          = ["arn:aws:iam::555555555555:role/ArchiveReader"]
  grant_account_ids      = ["666666666666"]
  tags                   = { Service = "archive", Component = "restore", ManagedBy = "fixture", Ticket = "LAB-42" }
}
