# AWS Configurer

Configures a static site distribution

1. Sets up an S3 Bucket
1. Sets a sample site to the bucket
1. Creates a Cloudfront Distribution to point to the bucket, which includes setting SSL Cert specified in ACM and also a cname so you can point a domain to it eventually