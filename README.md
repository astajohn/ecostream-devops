**EcoStream – Production Infrastructure Modernization (AWS)
**
Foundations Engineer Submission – Building a Secure Software Factory

📖 Project Overview

EcoStream is a green-energy monitoring startup preparing to scale from 5,000 to 500,000 users.

The legacy infrastructure had:

Dev/Test/Prod in same VPC

Manual SSH deployments

Unmanaged database

Hardcoded credentials

No monitoring or alerting

This project transforms that fragile setup into a secure, automated, scalable AWS 3-Tier architecture using Infrastructure as Code and CI/CD.

🏗 Architecture Overview
3-Tier Architecture (AWS – us-east-1)

Flow:

User Browser
⬇
Public Application Load Balancer (ALB)
⬇
Private Auto Scaling Group (EC2 – App Tier)
⬇
Private RDS MySQL (Multi-AZ in Production)

Key Design Principles

Public access limited to ALB only

App & DB fully private

Multi-AZ high availability

Infrastructure defined via Terraform

Fully automated Jenkins pipeline

🌍 Live Environments
🔹 Development

http://ecostream-dev-alb-1898340408.us-east-1.elb.amazonaws.com/

🔹 Production

http://ecostream-prod-alb-1832809077.us-east-1.elb.amazonaws.com/

🧱 Pillar Implementation
1️⃣ Isolation Strategy
Problem:

Dev once throttled Production database.

Solution:

Terraform Workspaces:

dev

prod

Branch-based deployment:

feature branches → dev

main → prod

TF_WORKSPACE = "${env.BRANCH_NAME == 'main' ? 'prod' : 'dev'}"
Production Safeguards:

Multi-AZ RDS enabled

Deletion protection enabled

Final snapshot enforced

Manual approval before apply

✅ Dev cannot accidentally modify Production.

2️⃣ The Assembly Line (CI/CD)
Before:

Manual SSH → git pull → restart → pray

After:

Automated Jenkins Pipeline

Pipeline Stages:

Checkout

Terraform Init

Terraform Validate

Terraform Plan

Manual Approval (Production only)

Terraform Apply

Post-Deployment Health Check

Safety Features:

disableConcurrentBuilds()

Manual approval for Production

Rolling Instance Refresh (ASG)

ALB health verification

Git-based rollback

✅ No SSH
✅ Fully automated
✅ Safe to deploy on Friday

3️⃣ Data Integrity & Evolution
Managed Database

Amazon RDS MySQL

Encrypted storage

Automated backups (7 days)

Maintenance window defined

Production High Availability

Multi-AZ enabled

Automatic failover

Final snapshot protection

Schema Change Strategy

Future-ready approach:

Versioned migrations (Flyway/Liquibase)

SQL changes stored in Git

CI executes migrations before deployment

Reversible rollback scripts

✅ No manual DB changes
✅ Hardware failure resilience

4️⃣ The Perimeter & Secrets
Network Security
Layer	Exposure
ALB	Public
App Tier	Private
Database	Private
Security Groups

ALB → allows HTTP (80) from Internet

App → only from ALB SG

DB → only from App SG

No SSH exposed

Secrets

RDS password managed by AWS

No credentials stored in Git

Designed for IAM role-based access

✅ Zero hardcoded secrets
✅ Zero public database

5️⃣ Observability (Nervous System)

CloudWatch + SNS Alerts configured for:

EC2 CPU > 80%

ALB 5XX error spikes

RDS low storage

Notifications sent via SNS email.

✅ Early detection
✅ Proactive alerting
✅ Reduced downtime risk

📦 Infrastructure Components

VPC (10.0.0.0/16)

Public & Private Subnets (Multi-AZ)

Internet Gateway

NAT Gateway

Application Load Balancer

Auto Scaling Group

Launch Template

RDS MySQL (Multi-AZ in prod)

CloudWatch Alarms

SNS Notifications

All managed via Terraform.

📅 Operational Runbook Summary
🟢 How Do We Deploy on a Friday Without Fear?

Git-based promotion

Terraform plan review

Manual approval (Prod)

Rolling deployment

Health check validation

Git revert for rollback

🔴 What Happens if the Database Vanishes?

Multi-AZ automatic failover

Automated backups

Point-in-time restore

Snapshot recovery

🚀 How Do We Handle 10x Traffic?

Auto Scaling Group scales horizontally

ALB distributes traffic

Stateless application tier

Multi-AZ high availability

🔧 Repository Structure
.
├── main.tf
├── vpc.tf
├── local.tf
├── output.tf
├── variables.tf
├── Jenkinsfile
└── README.md
🛠 Tech Stack

AWS

Terraform

Jenkins

Amazon RDS

Auto Scaling

Application Load Balancer

CloudWatch

SNS

👨‍💻 Author

Johnpeter E
DevOps Engineer

GitHub: https://github.com/astajohn


🎯 Outcome

EcoStream has transitioned from:

“Wild West Infrastructure”

To:

A secure, automated, production-ready Software Factory capable of supporting hyper-growth.
