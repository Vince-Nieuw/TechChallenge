echChallenge
Hello World!

#10 Feb 2025
Setup AWS, first thing to do was IAM and create a secondary account. Never use root for anything other than inial login. Generate API credentials for AWS CLI. Generate AWS IAM account for Github access, disable console, challenge: no policy for EKS. Gave full admin access (security risk, probs want to fix later //TODO)
20:41 - Restructured project and made a planning. Good to play around a bit, now lets get back in action.

Problem with AWS s3 bucket, received error:
```
Error: Failed to get existing workspaces: Unable to list objects in S3 bucket "terraform-remote-state-s3" with prefix "env:/": operation error S3: ListObjectsV2, https response error StatusCode: 301, RequestID: ZKGCAZ2HVBVQ52DJ, HostID: ZqUnDa3pUd/vwn66Q74yJhlh8prFUiJpiKh7K9YmEE+C48VYV1JOc0UrjYRtE/TzxlKr22Ua4dg=, requested bucket from "eu-north-1", actual location "us-east-1"

```
Woops, created the AWS bucket but under a different account. Quick google on AWS CLI and it taught me to recreate the bucket:
```
➜  .ssh aws s3api create-bucket --bucket terraform-remote-state-s3-vincenieuw --region eu-north-1 --create-bucket-configuration LocationConstraint=eu-north-1
aws s3api put-bucket-versioning --bucket terraform-remote-state-s3 --versioning-configuration Status=Enabled
```

Okay, have to create DYnamoDB database now. Never did this before, but wasn't too hard:

```
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-north-1
```

20:58, great success! [See pic 1.png]


# 11 Feb 2025

Lets go! Focus on VPC. Done, not a lot of constraints. Find a template on google and let's go next.
Also registered domain, so got that out of the way. The domain is `vince-techchallenge.com` and cost 14 dollars. Registered using AWS s3 so I don't have to fix the DNS-servers. 
Decided not to use terraform, not worth the hassle. Will likely regret this down the road.

