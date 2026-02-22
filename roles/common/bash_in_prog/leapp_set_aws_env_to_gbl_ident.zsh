#!/bin/bash
echo '$HOME/develop/platform_infrastructure_notes/__s3_replication/myleap.sh'
# Use IntelliJ special variable for the current project directory
# TERRAFORM_DIR="$HOME/develop/platform_infrastructure/components/terraform/s3-bread-app"  # Use IntelliJ's special variable for the current directory
# TERRAFORM_DIR="$PROJECT_DIR"  # Use IntelliJ's special variable for the current directory

# User-defined profile
# PROFILE_NAME="bd-gbl-root-terraform"  # Leapp profile name
echo "grabbing profile name from environment variable and hard coded gbl-idenity account to assume roles"
# Run Leapp session generate to get temporary credentials
echo "Generating Leapp session for profile '$PROFILE_NAME'..."
# should be the identity session, will assume the terraform-admin on terraform init
SESSION_OUTPUT=$(leapp session generate cf02160e-a117-4cf8-9c24-f823379e1eb7)
# SESSION_OUTPUT=$(leapp session generate f1ee8060-01ae-4ef0-8777-826a59c90515)

# [profile bd-gbl-identity-admin]
# source_profile = bd-gbl-identity
# role_arn = arn:aws:iam::921193560164:role/bd-gbl-identity-admin
# Check if the session was generated successfully\

# leapp session
if [ $? -ne 0 ]; then
  echo "Error: Failed to generate Leapp session."
  exit 1
fi

# Parse the output JSON to extract AWS credentials
export AWS_ACCESS_KEY_ID=$(echo "$SESSION_OUTPUT" | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$SESSION_OUTPUT" | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$SESSION_OUTPUT" | jq -r '.SessionToken')
export AWS_REGION="us-east-2"  # Set your desired region here

# Validate credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "Error: Failed to extract AWS credentials from Leapp session output."
  exit 1
fi

# Export credentials as environment variables
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
export AWS_REGION

echo "AWS credentials for profile '$PROFILE_NAME' exported successfully."
echo "Run ``env | grep AWS`` to verify"
