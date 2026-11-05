# Independent Deployment Guide (Fresh AWS Account)

This guide is for an engineer reproducing the project in **their own AWS account**. It is deliberately separate from the existing-deployment workflow: use a new state bucket and a dedicated AWS profile. Never point a fresh deployment at Pelumi's S3 bucket or state key.

> **Important:** This is a cost-conscious portfolio test environment, not a production architecture. It creates a VPC, six subnets, route tables, security groups, and one public `t3.micro` EC2 instance with an encrypted 8 GiB gp3 root volume. The EC2 test application is installed and started automatically by EC2 user-data during first boot. It does not create an ALB, NAT Gateway, or RDS database instance.

## 1. What you need

- An AWS account where you are authorized to create VPC, EC2, security-group, IAM instance-profile, and S3 resources.
- AWS CLI v2, Terraform 1.10.0 or later, and an internet connection for package installation during first boot.
- PowerShell 7 or Windows PowerShell 5.1 (commands below use PowerShell syntax).
- An AWS CLI profile for your own account. AWS IAM Identity Center/SSO is preferred.
- A globally unique S3 bucket name for your Terraform state.
- An administrator public IPv4 address for the temporary direct HTTP ingress rule.

The Terraform provider is constrained to AWS provider `~> 6.0`; the committed lock file selects version `6.71.0`. The configuration is pinned to Availability Zones `us-east-1a` and `us-east-1b` and defaults to region `us-east-1`.

## 2. Clone and authenticate

```powershell
git clone https://github.com/fhyxx/aws-three-tier-architecture.git
Set-Location .\aws-three-tier-architecture\terraform

# Configure an AWS IAM Identity Center profile if you do not already have one.
aws configure sso --profile project01

aws sso login --profile project01
$env:AWS_PROFILE = "project01"
$env:AWS_DEFAULT_REGION = "us-east-1"

aws sts get-caller-identity
terraform version
aws --version
```

Confirm that the returned AWS account ID is **your own account** before continuing. Use a profile that authenticates to the account where you are authorized to create the test resources. If you are the repository owner and `portfolio` is your own authorized profile, you may use it after verifying the account ID with `aws sts get-caller-identity`. Never use credentials belonging to another person or point this deployment at the repository owner's existing state bucket.

If your organization uses another approved credential mechanism, configure that instead. Do not put access keys in Terraform files, `terraform.tfvars`, or the repository.

## 3. Create a separate remote-state bucket

Choose a globally unique bucket name and retain it for this deployment:

```powershell
$AWS_REGION = "us-east-1"
$STATE_BUCKET = "REPLACE-WITH-A-GLOBALLY-UNIQUE-BUCKET-NAME"

aws s3api create-bucket --bucket $STATE_BUCKET --region $AWS_REGION
aws s3api put-public-access-block --bucket $STATE_BUCKET --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-versioning --bucket $STATE_BUCKET --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $STATE_BUCKET --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

The backend uses S3 native lockfiles (`use_lockfile = true`), so a separate DynamoDB lock table is not required. Keep bucket versioning enabled so earlier state versions can be recovered if needed. Restrict bucket access to the deployment identity and trusted administrators; do not make the bucket public.

Create the local backend file from the example and replace the placeholder bucket name and profile:

```powershell
Copy-Item .\backend.hcl.example .\backend.hcl
notepad .\backend.hcl
```

Set its values to your bucket, `us-east-1`, and `project01`. The file is git-ignored. Do not commit it.

## 4. Create the EC2 Systems Manager instance profile

The EC2 module expects an existing IAM instance profile. Create a role trusted by EC2 and attach the AWS-managed `AmazonSSMManagedInstanceCore` policy:

```powershell
@'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
'@ | Set-Content -Encoding ascii .\ec2-trust-policy.json

aws iam create-role --role-name project01-ec2-ssm-role --assume-role-policy-document file://ec2-trust-policy.json
aws iam attach-role-policy --role-name project01-ec2-ssm-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name project01-ec2-ssm-profile
aws iam add-role-to-instance-profile --instance-profile-name project01-ec2-ssm-profile --role-name project01-ec2-ssm-role
```

Allow a short period for IAM propagation before creating the EC2 instance. The identity running the commands needs permission to create and configure the S3 backend bucket, create the EC2 role/profile in this step, read the public AMI parameter (`ssm:GetParameter`), manage the required VPC/EC2/security-group resources, and pass only this EC2 role to the instance (`iam:PassRole`). For the S3 backend it needs bucket listing and state/lockfile object read, write, and lockfile-delete permissions. Scope resource permissions to the test account and resources where practical. Follow your organization's least-privilege process; do not grant broad administrator access solely to make the example work.

## 5. Set the deployment variables

Retrieve the current Amazon Linux 2023 x86-64 AMI ID from AWS Systems Manager Parameter Store and restrict direct HTTP access to your current public IPv4 address:

```powershell
$AMI_ID = aws ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --region $AWS_REGION --query Parameter.Value --output text
$ADMIN_CIDR = "$((Invoke-RestMethod -Uri 'https://checkip.amazonaws.com').Trim())/32"

Copy-Item .\terraform.tfvars.example .\terraform.tfvars
@"
aws_region            = "$AWS_REGION"
ami_id                = "$AMI_ID"
admin_cidr            = "$ADMIN_CIDR"
instance_profile_name = "project01-ec2-ssm-profile"
"@ | Set-Content -Encoding ascii .\terraform.tfvars
Get-Content .\terraform.tfvars
```

Review the generated values. `admin_cidr` is used for temporary direct HTTP access to the test instance. If your public IP changes, update it and review the resulting plan before applying. Do not publish your administrator IP address in screenshots, logs, or repository files.

## 6. Initialize, validate, and plan

Run from the `terraform` directory:

```powershell
terraform init -reconfigure -backend-config=backend.hcl
terraform fmt -check -recursive
terraform validate
terraform plan -out=project01.tfplan
terraform show project01.tfplan
```

The fresh-account plan should propose creating the project resources in **your** account. It should not show changes to resources in another account or reference the repository owner's S3 state. Review the plan for region, CIDRs, IAM profile, public IP assignment, user-data, and cost implications before applying.

For this independent deployment only, after reviewing the plan:

```powershell
terraform apply project01.tfplan
```

Capture the resulting identifiers:

```powershell
terraform output
$INSTANCE_ID = terraform output -raw instance_id
$PUBLIC_IP = terraform output -raw instance_public_ip
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[State.Name,Placement.AvailabilityZone,PublicIpAddress]' --output table
```

If Terraform reports an error, stop and resolve it before retrying. Do not switch to the repository owner's backend to work around an error.

## 7. Verify automatic EC2 user-data bootstrap

The application is intended to be installed and started by the EC2 user-data script during first boot. **Do not manually install packages, create the application files, or start/restart the service before recording the first-boot result.** Doing so would invalidate the bootstrap test.

First wait until the EC2 instance is registered as an online Systems Manager managed node:

```powershell
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE_ID" --query 'InstanceInformationList[0].[PingStatus,PlatformName]' --output table
```

When the instance reports `Online`, use Session Manager or a read-only Systems Manager Run Command to inspect the instance. SSM is an inspection and troubleshooting channel here; it is not the installation mechanism.

On the EC2 instance, check the user-data copy and cloud-init result:

```bash
# Confirm that EC2 received non-empty user-data without printing the script.
TOKEN=$(curl -fsS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data/ | wc -c
sudo wc -c /var/lib/cloud/instance/user-data.txt

# Inspect cloud-init completion and relevant setup output.
sudo cloud-init status --long
sudo tail -n 80 /var/log/cloud-init.log
sudo tail -n 80 /var/log/cloud-init-output.log
sudo tail -n 80 /var/log/pelumi-setup.log
```

Then verify the service and local HTTP endpoint:

```bash
sudo systemctl is-enabled pelumi-test.service
sudo systemctl is-active pelumi-test.service
sudo systemctl status pelumi-test.service --no-pager
sudo ss -lntp | grep ':80'
curl -i --max-time 5 http://127.0.0.1/
```

Expected results:

- The metadata and saved user-data copies are non-empty and have matching byte counts.
- Cloud-init reports completion.
- `pelumi-test.service` is enabled and active/running.
- A process is listening on TCP port 80.
- The local HTTP response is `200` and contains the expected AWS Three-Tier Architecture test page.

Finally, from PowerShell, verify external HTTP access:

```powershell
Invoke-WebRequest -Uri "http://$PUBLIC_IP/" -UseBasicParsing
```

Expected result: HTTP 200 and the test page content. If the local request succeeds but the external request fails, check the instance public IP, security-group ingress source, and whether your public IP still matches `admin_cidr`.

**Do not repair the instance before capturing the failed first-boot evidence.** If user-data or cloud-init fails, preserve the relevant logs and diagnose the cause. A manual installation through SSM may be useful as a separate troubleshooting experiment, but it must not be reported as a successful automatic-bootstrap test.

## 8. Understand the architecture and boundaries

- The VPC is `10.0.0.0/16` with six /24 subnets across two Availability Zones.
- Only the public subnets have a default route through the Internet Gateway.
- Application and database subnet route tables contain only the VPC-local route; no NAT Gateway is created.
- The EC2 test instance is placed in the first public subnet. It is not a private application-tier deployment.
- The test web security group allows TCP 80 from the configured administrator CIDR. Keep this narrow.
- The ALB security group and tier-to-tier rules are part of the network foundation, but no ALB or RDS database instance is created by this Terraform configuration.
- The EC2 root volume is encrypted gp3, 8 GiB. The instance uses IMDSv2 and an SSM instance profile.

This is a learning and portfolio environment, not a production-ready reference architecture. Do not expose it to real application data or production workloads.

## 9. Cost awareness and cleanup

The EC2 instance, EBS volume, public IPv4 address while allocated, S3 state storage, and data transfer can incur charges. Actual cost depends on region, usage, and current AWS pricing. The original project's $5 budget alert is not a hard spending cap. Check AWS Billing and Cost Management before and after testing.

**Important Terraform safety behavior:** the published modules deliberately use `lifecycle { prevent_destroy = true }` to protect the repository owner's existing infrastructure. A destroy plan from an untouched clone will therefore be blocked for protected resources. This is intentional and must not be removed from the owner's live configuration.

For your own disposable copy only, after confirming the AWS profile and backend point to your account, remove the `prevent_destroy = true` lifecycle guards from the copied network, security-group, and compute module files. In the compute module, retain the `ignore_changes = [user_data]` lifecycle setting. Then:

1. Run `terraform plan -destroy` and inspect every resource.
2. Confirm the plan contains only resources in your own test account and state.
3. Run `terraform destroy` only after that review.
4. Confirm the EC2 instance, VPC, subnets, route tables, Internet Gateway, and security groups have been removed.
5. Remove the test IAM instance profile and role created in section 4, after Terraform has destroyed the EC2 instance:

```powershell
aws iam remove-role-from-instance-profile --instance-profile-name project01-ec2-ssm-profile --role-name project01-ec2-ssm-role
aws iam delete-instance-profile --instance-profile-name project01-ec2-ssm-profile
aws iam detach-role-policy --role-name project01-ec2-ssm-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam delete-role --role-name project01-ec2-ssm-role
```

6. Retain the S3 state bucket until you no longer need the state history. If you choose to remove it, empty all object versions and delete it separately after confirming it contains no state you need.

Never remove the protection guards or run destroy commands against the repository owner's backend or AWS account.

## 10. Troubleshooting

- **S3 AccessDenied during init:** verify the selected profile, bucket name, region, and S3 permissions for state read/write and lockfile operations.
- **IAM PassRole error:** verify the caller can pass `project01-ec2-ssm-role` to EC2.
- **SSM node does not become Online:** verify the instance profile has `AmazonSSMManagedInstanceCore`, the instance has outbound HTTPS connectivity, and the AWS region/profile are correct.
- **Cloud-init reports failure:** inspect `cloud-init status --long`, `/var/log/cloud-init.log`, `/var/log/cloud-init-output.log`, and `/var/log/pelumi-setup.log` before making changes.
- **Service is missing or inactive:** preserve the first-boot evidence, inspect `systemctl status pelumi-test.service` and the setup log, and diagnose the user-data failure. Do not manually create the service and then claim the bootstrap test passed.
- **AMI not found:** rerun the Parameter Store lookup in `us-east-1` and confirm the returned AMI architecture is x86-64.
- **HTTP timeout:** confirm the instance is running, the test service is active, the public IP is correct, and your current public IP still matches `admin_cidr`.

## 11. What successful reproduction proves

A successful run demonstrates that another engineer can authenticate to an independent AWS account, create a separate remote state backend, prepare the required EC2 instance role, initialize and validate the Terraform configuration, review and apply a fresh-account plan, and have EC2 user-data automatically install and start the test application on first boot. The engineer can then verify the service and HTTP 200 response without manually installing or repairing the application through SSM.

This reproduction demonstrates a working network foundation and EC2 bootstrap path. It does not demonstrate a fully deployed production three-tier application, ALB, NAT Gateway, or RDS database.
