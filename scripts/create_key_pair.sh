#!/bin/bash
set -e

DEFAULT_PEM_FILE=~/.ssh/satellite-image-processing.pem
PEM_FILE=${1:-$DEFAULT_PEM_FILE}

if [ -f $PEM_FILE ]; then
  keypair_fingerprint=$(aws ec2 describe-key-pairs --key-name satellite-image-processing --output text --query 'KeyPairs[?KeyName==`development`].KeyFingerprint')
  pem_fingerprint=$(openssl pkcs8 -in ~/.ssh/satellite-image-processing.pem -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c)
  if [ "$keypair_fingerprint" == "$pem_fingerprint" ]; then
    echo "Keypair is already set up and ready to go"
    exit
  else
    echo "You already have a private key file '${PEM_FILE}' but it does not match the keypair on AWS" >&2
    echo "You will need to create a keypair manually or import your private key" >&2
    echo "See http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html" >&2
    exit 1
  fi
fi

aws ec2 create-key-pair --key-name satellite-image-processing --query 'KeyMaterial' --output text > $PEM_FILE
chmod 400 $PEM_FILE
echo "created key pair 'satellite-image-processing' and saved private key to $PEM_FILE"
