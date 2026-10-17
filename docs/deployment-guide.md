
# EC2 Application Deployment Guide

## 1. Objective

Deploy a lightweight web application on Amazon Linux 2023 and validate its availability using HTTP.

The existing EC2 instance was reused to keep project costs low.

## 2. Environment

| Component | Configuration |
|---|---|
| Cloud provider | Amazon Web Services |
| Region | us-east-1 |
| Operating system | Amazon Linux 2023 |
| Application | Python HTTP server |
| Web port | TCP 80 |
| Application directory | /opt/pelumi-test |
| Service manager | systemd |
| Administrative access | AWS Systems Manager Session Manager |

## 3. Administrative Access

AWS Systems Manager Session Manager was used to access the instance without relying on publicly exposed SSH access.

The instance has an IAM role configured with AmazonSSMManagedInstanceCore.

## 4. Application Deployment

The application was deployed in the existing EC2 instance.

Application directory:

/opt/pelumi-test

The web page displays a project heading and a successful deployment message.

A systemd unit named pelumi-test.service manages the Python HTTP server.

The service is configured to:

- Start automatically during system startup
- Restart if the process fails
- Serve the application directory on TCP port 80

## 5. Validation Procedures

### Check the service

```bash
sudo systemctl is-active pelumi-test.service
```

Expected output:

```text
active
```

### Test local HTTP access

```bash
curl -I --max-time 5 http://127.0.0.1/
```

Expected result: HTTP 200 OK.

### Confirm the listening port

```bash
sudo ss -lntp | grep ':80'
```

Expected result: a listening process on TCP port 80.

### Inspect service logs

```bash
sudo journalctl -u pelumi-test.service -n 50 --no-pager
```

### Check the setup log

```bash
sudo tail -n 50 /var/log/pelumi-setup.log
```

These checks help distinguish application-process failures from network-access problems.

## 6. External Access

The application was successfully accessed using the EC2 instance's public IPv4 address.

The instance's security group included HTTP access for testing.

For production, internet access should be restricted to the intended entry point, such as an Application Load Balancer.

## 7. Persistence Test

The application was tested after an EC2 reboot.

The service remained active and the web page was accessible.

This validated systemd-based service startup and basic recovery after a reboot.

## 8. Operational Considerations

- Confirm the instance subnet before classifying it as public or private.
- Restrict inbound access to approved sources.
- Avoid exposing SSH unnecessarily when Session Manager is available.
- Monitor EC2 and EBS charges.
- Use a production web server and appropriate application hardening before real-world deployment.
- Use HTTPS and appropriate logging for a production-facing application.

## 9. Scope and Limitations

This is a portfolio demonstration, not a production-hardened web application.

The Python HTTP server is suitable for lightweight testing but is not recommended as a production web server.

No RDS database instance or NAT Gateway was deployed.
