# Independent Deployment Guide (Fresh AWS Account)

This guide is for a technically competent engineer reproducing the project in **their own AWS account**. It is deliberately separate from the existing-deployment workflow: use a new state bucket and a dedicated AWS profile. Never point a fresh deployment at Pelumi's S3 bucket or state key.

> **Important:** This is a portfolio test environment, not a production architecture. It creates a VPC, six subnets, route tables, security groups, and one public `t3.micro` EC2 instance with an encrypted 8 GiB gp3 root volume. It does not create an ALB, NAT Gateway, or RDS database instance. The EC2 test application is installed separately through Systems Manager in the steps below.

## 1. What you need

- An AWS account where you are authorized to create VPC, EC2, security-group, IAM instance-profile, and S3 resources.
- AWS CLI v2, the AWS Systems Manager Session Manager plugin, and Terraform 1.10.0 or later.
- PowerShell 7 or Windows PowerShell 5.1 (commands below use PowerShell syntax).
- An AWS CLI profile for your own account. AWS IAM Identity Center/SSO is preferred.
- A globally unique S3 bucket name for your Terraform state.

The Terraform provider is constrained to AWS provider `~> 6.0`; the committed lock file currently selects version `6.71.0`. The configuration is pinned to Availability Zones `us-east-1a` and `us-east-1b` and defaults to region `us-east-1`.

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

Confirm that the returned AWS account ID is **your own account** before continuing. Do not use the `portfolio` profile or credentials belonging to the repository owner.

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
$ADMIN_CIDR = "$( (Invoke-RestMethod -Uri 'https://checkip.amazonaws.com').Trim() )/32"

Copy-Item .\terraform.tfvars.example .\terraform.tfvars
@"
aws_region            = "$AWS_REGION"
ami_id                = "$AMI_ID"
admin_cidr            = "$ADMIN_CIDR"
instance_profile_name = "project01-ec2-ssm-profile"
"@ | Set-Content -Encoding ascii .\terraform.tfvars
Get-Content .\terraform.tfvars
```

Review the generated values. `admin_cidr` is used for temporary direct HTTP access to the test instance. If your public IP changes, update it and review the resulting plan before applying.

## 6. Initialize, validate, and plan

Run from the `terraform` directory:

```powershell
terraform init -reconfigure -backend-config=backend.hcl
terraform fmt -check -recursive
terraform validate
terraform plan -out=project01.tfplan
terraform show project01.tfplan
```

The fresh-account plan should propose creating the project resources in **your** account. It should not show changes to resources in another account or reference the repository owner's S3 state. Review the plan for region, CIDRs, IAM profile, public IP assignment, and cost implications before applying.

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

## 7. Install and verify the web test application

Wait until the EC2 instance is registered as an online Systems Manager managed node:

```powershell
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE_ID" --query 'InstanceInformationList[0].[PingStatus,PlatformName]' --output table
```

When the instance reports `Online`, start a Session Manager shell:

```powershell
aws ssm start-session --target $INSTANCE_ID --region $AWS_REGION
```

In the Linux session, install and configure the same lightweight Python HTTP test application documented by this project:

```bash
sudo dnf install -y python3
sudo mkdir -p /opt/pelumi-test
echo '<html><body><h1>AWS Three-Tier Architecture</h1><p>EC2 web test application is running.</p></body></html>' | sudo tee /opt/pelumi-test/index.html

sudo tee /etc/systemd/system/pelumi-test.service > /dev/null <<'EOF'
[Unit]
Description=Pelumi EC2 Test Web Application
After=network.target

[Service]
Type=simple
User=nobody
Group=nobody
AmbientCapabilities=CAP_NET_BIND_SERVICE
WorkingDirectory=/opt/pelumi-test
ExecStart=/usr/bin/python3 -m http.server 80 --directory /opt/pelumi-test
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now pelumi-test.service
sudo systemctl is-active pelumi-test.service
curl -I --max-time 5 http://127.0.0.1/
```

Exit the Session Manager session, then from PowerShell verify external HTTP access from the administrator IP configured in `admin_cidr`:

```powershell
Invoke-WebRequest -Uri "http://$PUBLIC_IP/" -UseBasicParsing
```

Expected result: HTTP 200 and the test page content. This reproduces the simple EC2 web test workload; it does not deploy an ALB or a database.

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
5. Retain the S3 state bucket until you no longer need the state history. If you choose to remove it, empty all object versions and delete it separately after confirming it contains no state you need.

Never remove the protection guards or run destroy commands against the repository owner's backend or AWS account.

## 10. Troubleshooting

- **S3 AccessDenied during init:** verify the selected profile, bucket name, region, and S3 permissions for state read/write and lockfile operations.
- **IAM PassRole error:** verify the caller can pass `project01-ec2-ssm-role` to EC2.
- **SSM node does not become Online:** verify the instance profile has `AmazonSSMManagedInstanceCore`, the instance has outbound HTTPS connectivity, and the AWS region/profile are correct.
- **AMI not found:** rerun the Parameter Store lookup in `us-east-1` and confirm the returned AMI architecture is x86-64.
- **HTTP timeout:** confirm the instance is running, the test service is active, the public IP is correct, and your current public IP still matches `admin_cidr`.

## 11. What successful reproduction proves

A successful run demonstrates that another engineer can authenticate to an independent AWS account, create a separate remote state backend, prepare the required EC2 instance role, initialize and validate the Terraform configuration, review and apply a fresh-account plan, deploy the EC2 test application through Systems Manager, and verify HTTP 200 without access to the repository owner's AWS account or state.
