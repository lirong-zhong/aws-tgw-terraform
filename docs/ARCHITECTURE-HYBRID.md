# 4-Region Hybrid Architecture with SD-WAN + Direct Connect

## Architecture Diagram

```
┌──────────────────┐                                                    ┌──────────────────┐
│  PARIS DC        │                                                    │  FRANKFURT DC    │
│  10.100.0.0/16   │                                                    │  10.101.0.0/16   │
│  [CPE]           │                                                    │  [CPE]           │
└────────┬─────────┘                                                    └────────┬─────────┘
         │                                                                       │
    Direct Connect                                                          SD-WAN
         │                                                                  (Internet)
         │                        AWS CLOUD                                      │
┌────────┼───────────────────────────────────────────────────────────────────────┼────────┐
│        │                                                                       │        │
│  ┌─────▼──────────────────────┐                    ┌───────────────────────────▼─────┐  │
│  │  PARIS (eu-west-3)         │                    │  FRANKFURT (eu-central-1)       │  │
│  │  VPC: 10.1.0.0/16          │                    │  VPC: 10.2.0.0/16               │  │
│  │                            │                    │                                 │  │
│  │  ┌────────┐  ┌────────┐    │                    │  ┌────────┐                     │  │
│  │  │SD-WAN  │  │SD-WAN  │    │                    │  │SD-WAN  │                     │  │
│  │  │Control │  │vCPE    │    │                    │  │vCPE    │                     │  │
│  │  │(EC2)   │  │(EC2)   │    │                    │  │(EC2)   │                     │  │
│  │  └────────┘  └───┬────┘    │                    │  └───┬────┘                     │  │
│  │                  │         │                    │      │                          │  │
│  │  ┌───────────────▼───────┐ │    TGW Peering    │  ┌───▼───────────────────────┐  │  │
│  │  │ TGW (ASN:64512)       │◄├───────────────────┼─►│ TGW (ASN:64513)           │  │  │
│  │  │ + DXGW Attachment     │ │        (1)        │  │                           │  │  │
│  │  └───────────┬───────────┘ │                    │  └───────────┬───────────────┘  │  │
│  └──────────────┼─────────────┘                    └──────────────┼──────────────────┘  │
│                 │╲                                               ╱│                     │
│                 │ ╲                                             ╱ │                     │
│                 │  ╲           (2)             (4)             ╱  │                     │
│                 │   ╲                                         ╱   │                     │
│                 │    ╲                                       ╱    │                     │
│                 │     ╲                                     ╱     │                     │
│                 │  (3) ╲                                   ╱ (5)  │                     │
│                 │       ╲                                 ╱       │                     │
│                 │        ╲                               ╱        │                     │
│                 │         ╲                             ╱         │                     │
│  ┌──────────────┼──────────╲───────────────────────────╱──────────┼──────────────────┐  │
│  │              │           ╲                         ╱           │                  │  │
│  │  ┌───────────▼───────┐    ╲         (6)          ╱    ┌───────▼───────────────┐  │  │
│  │  │ TGW (ASN:64514)   │◄────╲─────────────────────╱───►│ TGW (ASN:64515)       │  │  │
│  │  │                   │      ╲                   ╱     │                       │  │  │
│  │  └───────────┬───────┘       ╲                 ╱      └───────────┬───────────┘  │  │
│  │              │                ╲               ╱                   │              │  │
│  │  ┌───────────▼───────┐         ╲             ╱        ┌───────────▼───────┐      │  │
│  │  │SD-WAN vCPE (EC2)  │          ╲           ╱         │SD-WAN vCPE (EC2)  │      │  │
│  │  └───────────────────┘           ╲         ╱          └───────────────────┘      │  │
│  │                                   ╲       ╱                                      │  │
│  │  VPC: 10.3.0.0/16                  ╲     ╱            VPC: 10.4.0.0/16           │  │
│  │  IRELAND (eu-west-1)                ╲   ╱             STOCKHOLM (eu-north-1)     │  │
│  └──────────────┬───────────────────────╲─╱──────────────────────┬──────────────────┘  │
│                 │                                                │                     │
└─────────────────┼────────────────────────────────────────────────┼─────────────────────┘
                  │                                                │
              SD-WAN                                           SD-WAN
             (Internet)                                       (Internet)
                  │                                                │
┌─────────────────▼────────┐                          ┌────────────▼─────────────────┐
│  IRELAND DC              │                          │  STOCKHOLM DC                │
│  10.102.0.0/16           │                          │  10.103.0.0/16               │
│  [CPE]                   │                          │  [CPE]                       │
└──────────────────────────┘                          └──────────────────────────────┘


TGW Full Mesh Peering (6 connections):
  (1) Paris     ◄──► Frankfurt
  (2) Paris     ◄──► Ireland
  (3) Paris     ◄──► Stockholm
  (4) Frankfurt ◄──► Ireland
  (5) Frankfurt ◄──► Stockholm
  (6) Ireland   ◄──► Stockholm
```

## Components Summary

| Region | VPC CIDR | TGW ASN | SD-WAN | On-Prem Connection | On-Prem CIDR |
|--------|----------|---------|--------|-------------------|--------------|
| Paris | 10.1.0.0/16 | 64512 | Controller + vCPE | Direct Connect | 10.100.0.0/16 |
| Frankfurt | 10.2.0.0/16 | 64513 | vCPE | SD-WAN (Internet) | 10.101.0.0/16 |
| Ireland | 10.3.0.0/16 | 64514 | vCPE | SD-WAN (Internet) | 10.102.0.0/16 |
| Stockholm | 10.4.0.0/16 | 64515 | vCPE | SD-WAN (Internet) | 10.103.0.0/16 |

## TGW Attachments Per Region

| Region | VPC | TGW Peering | DX Gateway |
|--------|-----|-------------|------------|
| Paris | ✓ | 3 | ✓ |
| Frankfurt | ✓ | 3 | - |
| Ireland | ✓ | 3 | - |
| Stockholm | ✓ | 3 | - |

## New Terraform Modules Required

1. `modules/sdwan-controller/` - SD-WAN Controller EC2 (Paris only)
2. `modules/sdwan-edge/` - SD-WAN vCPE EC2 (all 4 regions)
3. `modules/dx-gateway/` - Direct Connect Gateway (Paris only)
