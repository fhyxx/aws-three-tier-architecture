# Terraform and EC2 Validation Evidence

**Validation date:** November 2, 2026  
**AWS region:** `us-east-1`

This record captures the checks performed after replacing the EC2 root EBS volume with an encrypted volume and reconciling the Terraform configuration.

## Terraform

Commands executed:

```powershell
terraform fmt
terraform validate
terraform plan
```

Results:

- Formatting completed.
- Validation returned: `Success! The configuration is valid.`
- Plan returned: `No changes. Your infrastructure matches the configuration.`
- The S3 state lock was acquired and released successfully.

## EBS Root Volume

| Property | Observed value |
|---|---|
| Replacement volume | `vol-024b4f81c7142aada` |
| Volume type | gp3 |
| Size | 8 GiB |
| Encrypted | True |
| State | in-use |

The previous root volume was retained during replacement for rollback purposes.

## EC2 Health

| Property | Observed value |
|---|---|
| Instance | `i-00753e5b7bc4fce29` |
| Instance state | running |
| System status | ok |
| Instance status | ok |
| Public IP | `100.55.74.207` |
| Private IP | `10.0.1.138` |

## Application Check

The HTTP check returned:

```text
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.9.25
Content-type: text/html
```

This confirms the web test application responded successfully at the time of validation.

## Systems Manager

The instance information query returned:

```text
Instance: i-00753e5b7bc4fce29
Ping: Online
```

This confirms Systems Manager connectivity at the time of validation.

## Scope and Limitations

These are point-in-time checks, not continuous monitoring or an uptime guarantee. They do not establish that an ALB, NAT Gateway, or RDS database is deployed. Those resources are not currently part of the running environment.
