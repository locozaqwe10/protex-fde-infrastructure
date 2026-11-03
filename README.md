# protex-fde-infrastructure

Network layer for a central observability platform that reads from Protex's regional AWS stacks
(EU, US, CA, APAC) without moving data out of region. Take-home for the FDE role.

Two central hubs (Region A + Region B) run active/active behind Route 53 health-based routing
for 99.9999% uptime. Each hub peers with all 4 regional VPCs.

## Layout

```
terraform/
  modules/
    vpc/               tiered VPC (public + private), NAT, IGW, per-tier route tables
    vpc_endpoints/     interface + gateway endpoints for AWS API access
    vpc_peering/       cross-account cross-region VPC peering, 2-way routes
    spoke_attachment/  looks up a regional VPC for peering
  stacks/
    central_hub/       one hub: VPC + ALB + endpoints + Redis + 4 peerings (deploy twice)
```
