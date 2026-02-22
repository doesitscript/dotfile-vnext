#!/usr/bin/env bash
script_name=$0
echo $script_name

codefresh completion zsh >> ~/.zshrc

# rint completion script for codefresh aliased as “cf”
echo "codefresh completion not setup to work with alias cf"
# codefresh completion --alias cf
