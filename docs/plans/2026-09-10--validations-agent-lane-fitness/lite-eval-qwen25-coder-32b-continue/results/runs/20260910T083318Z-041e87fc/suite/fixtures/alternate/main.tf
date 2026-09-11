# Synthetic grounded values: these identify no deployed resources.
locals {
  deployment_account_id = data.aws_caller_identity.current.account_id
  config = {
    kms = {
      alias_name = "archive-sandbox"
      description = "Archive test key; resource text in a string is not a block"
      key_administrator_arns = ["arn:aws:iam::555555555555:role/ArchiveMaintainer"]
      key_user_arns = ["arn:aws:iam::555555555555:role/ArchiveReader"]
      grant_account_ids = ["666666666666"]
      tags = { Service = "archive", Component = "restore", ManagedBy = "fixture", Ticket = "LAB-42" }
    }
  }
}
