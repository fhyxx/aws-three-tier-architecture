
# AWS Troubleshooting Case Study

## Incident: Application Load Balancer Target Health

### 1. Situation

A temporary Application Load Balancer was configured to route HTTP traffic to an existing EC2 web application.

The target initially reported an unhealthy status because health-check requests timed out.

### 2. Initial Investigation

The investigation focused on separating application-level failures from network-level failures.

Checks performed included:

- Confirming the systemd service was active
- Testing the application locally with curl
- Confirming the application listened on TCP port 80
- Reviewing the application security group
- Confirming the load balancer security group allowed outbound traffic
- Reviewing the target group health status

### 3. Findings

The local application test returned HTTP 200 OK.

The web service was listening on TCP port 80.

The target subsequently became healthy, and the application was accessible through the load balancer DNS endpoint.

The exact root cause of the initial timeout was not conclusively established.

### 4. Resolution and Cleanup

The load balancer and target group were successfully tested.

They were subsequently deleted to avoid unnecessary ongoing charges.

The existing EC2 instance and attached EBS volume were preserved.

The application remained accessible directly through the EC2 public IPv4 address.

### 5. Lessons Learned

- Validate application health independently of load balancer health.
- Confirm that the target group uses the correct protocol and port.
- Verify security group rules in both directions of the intended connection.
- Check subnet routing and network ACLs when timeouts persist.
- Review target health-reason messages rather than guessing the root cause.
- Validate functionality before deleting temporary test resources.
- Keep cost controls in mind during cloud experimentation.

### 6. Future Improvements

- Capture target health-reason messages during failures.
- Verify the actual EC2 subnet and route table.
- Use CloudWatch metrics and logs where appropriate.
- Deploy the application in the intended private application tier.
- Use an Application Load Balancer as the controlled public entry point.
- Introduce infrastructure automation and repeatable deployment procedures.

## Interview Summary

I deployed a lightweight web application on an existing Amazon EC2 instance, validated it independently, and tested access through an Application Load Balancer.

When the target initially reported a timeout, I checked application health, the listening port, and security group configuration. The target later became healthy and the application was successfully served through the load balancer.

After testing, I removed the temporary load balancer resources to control costs while preserving the working instance and its attached storage.

I would not attribute the initial timeout to a specific root cause without sufficient evidence.
