#!/bin/bash
set -e

existing_security_group=$(aws ec2 describe-security-groups --output text --query 'SecurityGroups[?GroupName==`ssh-only`]')

if [ -n "$existing_security_group" ]; then
  echo "Security group ssh-only already exists, looks like you are all set to go"
  exit
fi

echo "creating security group ssh-only"
aws ec2 create-security-group --group-name ssh-only --description "Only allow port 22 ssh access" --output json
echo "adding ip permission for port 22 from any IP to security group"
aws ec2 authorize-security-group-ingress --group-name ssh-only --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 describe-security-groups --group-name ssh-only --output json
