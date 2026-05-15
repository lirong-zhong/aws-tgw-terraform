# 4-Region Full Mesh TGW Design

## Overview

This design adds 2 new regions (eu-west-1, eu-west-2) to create a 4-region full mesh Transit Gateway architecture with 6 peering connections.

## Regions

| # | Region | Code | VPC CIDR | TGW ASN |
|---|--------|------|----------|---------|
| 1 | Paris | eu-west-3 | 10.1.0.0/16 | 64512 |
| 2 | Frankfurt | eu-central-1 | 10.2.0.0/16 | 64513 |
| 3 | Ireland | eu-west-1 | 10.3.0.0/16 | 64514 |
| 4 | London | eu-west-2 | 10.4.0.0/16 | 64515 |

## Full Mesh Peering (6 Connections)

```
                    ┌─────────────┐
                    │   Ireland   │
                    │  eu-west-1  │
                    │ 10.3.0.0/16 │
                    └──────┬──────┘
                          /│\
                         / │ \
                        /  │  \
                       /   │   \
    ┌─────────────┐   /    │    \   ┌─────────────┐
    │    Paris    │──/─────┼─────\──│   London    │
    │  eu-west-3  │ /      │      \ │  eu-west-2  │
    │ 10.1.0.0/16 │/       │       \│ 10.4.0.0/16 │
    └──────┬──────┘        │        └──────┬──────┘
            \              │              /
             \             │             /
              \            │            /
               \           │           /
                \          │          /
                 \         │         /
                  \        │        /
                   \       │       /
                    \      │      /
                     \     │     /
                      \    │    /
                       \   │   /
                        \  │  /
                         \ │ /
                          \│/
                    ┌──────┴──────┐
                    │  Frankfurt  │
                    │ eu-central-1│
                    │ 10.2.0.0/16 │
                    └─────────────┘
```

## 6 Peering Connections

| # | Requester | Accepter | Route |
|---|-----------|----------|-------|
| 1 | Paris (eu-west-3) | Frankfurt (eu-central-1) | 10.1↔10.2 |
| 2 | Paris (eu-west-3) | Ireland (eu-west-1) | 10.1↔10.3 |
| 3 | Paris (eu-west-3) | London (eu-west-2) | 10.1↔10.4 |
| 4 | Frankfurt (eu-central-1) | Ireland (eu-west-1) | 10.2↔10.3 |
| 5 | Frankfurt (eu-central-1) | London (eu-west-2) | 10.2↔10.4 |
| 6 | Ireland (eu-west-1) | London (eu-west-2) | 10.3↔10.4 |

## Resources Per Region

Each region will have:
- 1 VPC with public, private, and TGW subnets
- 1 Transit Gateway
- 1 NAT Gateway
- 1 Internet Gateway
- Route tables with routes to all other 3 VPCs
- 1 Test EC2 instance (optional)

## Route Table Configuration

Each TGW route table needs routes to 3 other VPCs:

**Paris TGW Routes:**
- 10.2.0.0/16 → Peering to Frankfurt
- 10.3.0.0/16 → Peering to Ireland
- 10.4.0.0/16 → Peering to London

**Frankfurt TGW Routes:**
- 10.1.0.0/16 → Peering to Paris
- 10.3.0.0/16 → Peering to Ireland
- 10.4.0.0/16 → Peering to London

**Ireland TGW Routes:**
- 10.1.0.0/16 → Peering to Paris
- 10.2.0.0/16 → Peering to Frankfurt
- 10.4.0.0/16 → Peering to London

**London TGW Routes:**
- 10.1.0.0/16 → Peering to Paris
- 10.2.0.0/16 → Peering to Frankfurt
- 10.3.0.0/16 → Peering to Ireland

## Cost Estimate (Monthly)

| Resource | Qty | Unit Cost | Total |
|----------|-----|-----------|-------|
| Transit Gateway | 4 | $36.50 | $146 |
| TGW Peering Attachments | 6 | $36.50 | $219 |
| NAT Gateway | 4 | $32.40 | $130 |
| VPC Flow Logs | 4 | ~$10 | $40 |
| **Total** | | | **~$535/month** |

*Note: Data transfer costs are additional*

## Implementation Plan

1. Add 2 new providers (Ireland, London)
2. Create 2 new VPCs with TGWs
3. Create 4 new peering connections
4. Update all route tables
5. Create test instances
6. Verify connectivity

## Questions for Confirmation

1. Are the CIDR blocks (10.1-10.4.0.0/16) acceptable?
2. Do you need test EC2 instances in all 4 regions?
3. Should we use single NAT Gateway (cost saving) or HA (one per AZ)?
4. Any specific naming convention required?

**Please confirm this design to proceed with implementation.**
