#!/bin/bash
set -e

read -d '' ec2_role_trust_policy << EOM || true
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOM

read -d '' ec2_role_access_policy << EOM || true
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["*"]
    }
  ]
}
EOM

existing_instance_profile=$(aws iam list-instance-profiles --output text --query 'InstanceProfiles[?InstanceProfileName==`S3-Permissions`]')

if [ -n "$existing_instance_profile" ]; then
  echo "You already have an instance profile S3-Permissions, looks like you are all set to go"
  exit
fi

echo "creating role s3access"
aws iam create-role --role-name s3access --assume-role-policy-document "$ec2_role_trust_policy" --output json
echo "adding s3 permissions to role"
aws iam put-role-policy --role-name s3access --policy-name S3-Permissions --policy-document "$ec2_role_access_policy" --output json
echo "creating instance profile S3-Permissions"
aws iam create-instance-profile --instance-profile-name S3-Permissions
echo "adding role to instance profile"
aws iam add-role-to-instance-profile --instance-profile-name S3-Permissions --role-name s3access
