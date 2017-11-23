#!/bin/bash
S3_BUCKET_NAME=''
S3_BUCKET_REGION='ap-southeast-2'
CERTIFICATE_ARN=''
CNAME=''

# Get arguments if they exists
while getopts 'b:r:c:a' flag; do
  case "${flag}" in
    b) S3_BUCKET_NAME="${OPTARG}" ;;
    r) S3_BUCKET_REGION="${OPTARG}" ;;
    c) CNAME="${OPTARG}" ;;
    a) CERTIFICATE_ARN="${OPTARG}" ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

if [ -z "$S3_BUCKET_NAME" ]
then
  echo "Please specify a buckket name to create"
  echo "aws-s3.sh -b [BUCKET_NAME]"
if [ -z "$CNAME" ]
then
  echo "Please specify a CNAME to create"
  echo "aws-s3.sh -c [CNAME]"
if [ -z "$CERTIFICATE_ARN" ]
then
  echo "Please specify a Cert to create"
  echo "aws-s3.sh -a [CERTIFICATE_ARN]"
else
  echo "Creating S3 Bucket ${S3_BUCKET_NAME} in region ${S3_BUCKET_REGION}..."
  # Create the S3 Bucket
  aws s3 mb s3://$S3_BUCKET_NAME --region $S3_BUCKET_REGION

  echo 'Bucket created, setting bucket as website'
  # Set the bucket as a website
  aws s3 website s3://$S3_BUCKET_NAME/ --index-document index.html --error-document index.html

  aws s3 sync "sample-site" "s3://$S3_BUCKET_NAME" --delete --acl public-read

  BUCKET_URL="$S3_BUCKET_NAME.s3-website-$S3_BUCKET_REGION.amazonaws.com"

  echo "Website set @ http://${BUCKET_URL}"

  echo "Setting up cloudfront distribution"
  gulp generate-config --domain $BUCKET_URL --certificate $CERTIFICATE_ARN --cname $CNAME
  aws cloudfront create-distribution \
    --distribution-config file://config/cloudfront-config.json >> config/final-config.json
  
  echo "Cloudfront set up"
fi

