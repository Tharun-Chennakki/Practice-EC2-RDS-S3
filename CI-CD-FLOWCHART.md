```
╔════════════════════════════════════════════════════════════════════════════╗
║                   GitHub Actions CI/CD Pipeline Setup                      ║
║                        Complete & Ready to Deploy                          ║
╚════════════════════════════════════════════════════════════════════════════╝

📦 PROJECT STRUCTURE
═══════════════════════════════════════════════════════════════════════════

AWS-EC2-RDS-S3/
├── 📁 .github/                           ← GitHub Configuration
│   ├── 📁 workflows/
│   │   ├── ci.yml                        ✨ CI Workflow (Auto on Push)
│   │   └── cd.yml                        ✨ CD Workflow (Manual Trigger)
│   ├── 📁 scripts/
│   │   ├── deploy.ps1                    ⚙️  Main Deployment Script (PowerShell)
│   │   ├── setup-secrets.ps1             🔑 Secrets Configuration Helper
│   │   └── health-check.ps1              ✅ Health Check Script
│   └── DEPLOYMENT_GUIDE.md               📖 Detailed Deployment Guide
│
├── 📁 tests/
│   └── test_app.py                       ✨ Test Suite
│
├── 📁 templates/                         (Existing)
├── 📁 static/                            (Existing)
├── app.py                                (Existing)
├── requirements.txt                      (Existing)
├── README.md                             (Existing)
│
├── CI-CD-SETUP.md                        📖 Complete Setup Guide
├── QUICK-REFERENCE.md                    📖 Quick Start Guide
├── .env.example                          📋 Environment Template
├── .gitignore                            🚫 Git Ignore Rules
└── CI-CD-FLOWCHART.md                    📊 This File

═════════════════════════════════════════════════════════════════════════════

🔄 WORKFLOW FLOW DIAGRAM
═════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ Developer Pushes Code to GitHub Main Branch                             │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                    ┌────────────▼──────────┐
                    │  CI WORKFLOW STARTS   │
                    │  .github/workflows/   │
                    │      ci.yml           │
                    └────────┬───────────────┘
                             │
                    ┌────────▼──────────────────────────────┐
                    │ CI Jobs (Parallel on 3.9, 3.10, 3.11):│
                    ├──────────────────────────────────────┤
                    │ 1. Checkout Code                     │
                    │ 2. Setup Python Environment          │
                    │ 3. Install Dependencies              │
                    │ 4. Run Linting (flake8)              │
                    │ 5. Check Code Format (black)         │
                    │ 6. Security Scan (bandit)            │
                    │ 7. Vulnerability Check (safety)      │
                    │ 8. Run Unit Tests (pytest)           │
                    │ 9. Validate Flask App                │
                    └────────┬─────────────────────────────┘
                             │
                    ╔════════▼═════════╗
                    │ CI Tests Pass?   │
                    ╚════════╤═════════╝
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            NO               │ YES            │
            │                │                │
        ┌───▼──────┐         │         ┌─────▼────────────────────┐
        │  FAIL ✗  │         │         │  TRIGGER CD WORKFLOW ✓   │
        │  STOP    │         │         │  (Auto on main branch)   │
        └──────────┘         │         └─────┬────────────────────┘
                             │               │
                             │               │
                    ╔════════▼═══════════════▼════════════╗
                    │   CD WORKFLOW CAN START             │
                    │  .github/workflows/cd.yml           │
                    │                                     │
                    │ Triggers:                           │
                    │ • Auto from CI (main branch)        │
                    │ • Manual via GitHub UI              │
                    ╚════════╤═══════════════════════════╝
                             │
                    ┌────────▼──────────────────────────────┐
                    │ CD Jobs:                             │
                    ├──────────────────────────────────────┤
                    │ 1. Pre-Deployment Checks             │
                    │    - Generate Deployment ID          │
                    │    - Validate Configuration          │
                    │                                      │
                    │ 2. Optional: Run Tests               │
                    │    - Pytest Suite                    │
                    │                                      │
                    │ 3. Deploy to AWS EC2                 │
                    │    - Setup SSH Connection            │
                    │    - Upload Deployment Script        │
                    │    - Execute Remote Script:          │
                    │      • Create Backups                │
                    │      • Git Pull Latest Code          │
                    │      • Install Dependencies          │
                    │      • Create/Update .env            │
                    │      • Setup Systemd Service         │
                    │      • Restart Flask Application     │
                    │                                      │
                    │ 4. Post-Deployment Health Check      │
                    │    - HTTP Endpoint Verification      │
                    │    - Retry Logic (5 attempts)        │
                    │                                      │
                    │ 5. Optional: Slack Notification      │
                    │    - Deployment Status              │
                    │    - Details (ID, Actor, Commit)    │
                    └────────┬──────────────────────────────┘
                             │
                    ╔════════▼═════════╗
                    │ Deployment OK?   │
                    ╚════════╤═════════╝
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            │               YES              │
            │                │                │
            │        ┌───────▼─────────┐     │
            │        │  SUCCESS! ✓     │     │
            │        │  Application    │     │
            │        │  Deployed to    │     │
            │        │  AWS EC2        │     │
            │        │  http://ec2-ip:5000
            │        └─────────────────┘     │
            │                                │
        ┌───▼──────────────────┐             │
        │ FAILURE ✗            │             │
        │ Check Logs:          │             │
        │ • GitHub Actions     │             │
        │ • EC2 App Logs       │             │
        │ • RDS Connection     │             │
        └──────────────────────┘             │
                                             │

═════════════════════════════════════════════════════════════════════════════

📊 DEPLOYMENT TIMELINE
═════════════════════════════════════════════════════════════════════════════

Push to GitHub
    ↓ (~5 seconds)
GitHub Actions Triggered
    ↓
CI Workflow Starts (~3-5 minutes)
├─ Setup & Install (~1 min)
├─ Lint & Security (~1 min)
├─ Tests (~1-2 min)
└─ Complete
    ↓
CI Pass? → Auto-trigger CD (main branch only)
    ↓
CD Workflow Starts (~2-3 minutes)
├─ Pre-deployment checks (~30 sec)
├─ Run tests (optional, ~1 min)
├─ Deploy via SSH (~1 min)
│  ├─ Upload scripts
│  ├─ Git pull & install
│  ├─ Configure env
│  └─ Restart service
├─ Health check (~30 sec)
└─ Complete
    ↓
Application Live on EC2! ✓

Total Time: 5-8 minutes from push to production deployment

═════════════════════════════════════════════════════════════════════════════

🎛️ WORKFLOW TRIGGERS & OPTIONS
═════════════════════════════════════════════════════════════════════════════

CI WORKFLOW (.github/workflows/ci.yml)
────────────────────────────────────────
Automatic Triggers:
  • Push to main branch
  • Push to develop branch
  • Pull Request to any branch

No user options needed - runs automatically!

───────────────────────────────────────────

CD WORKFLOW (.github/workflows/cd.yml)
────────────────────────────────────────
Trigger Method: Manual (workflow_dispatch)

How to Trigger:
  1. Go to GitHub repository
  2. Click "Actions" tab
  3. Select "CD - Deploy to AWS EC2"
  4. Click "Run workflow" ▼
  5. Configure options (see below)
  6. Click "Run workflow" button

Configuration Options:
  ┌──────────────────────────────────────┐
  │ Deploy Target (required)             │
  │ • staging    - Test environment      │
  │ • production - Live environment      │
  │                                      │
  │ Skip Tests (optional)                │
  │ • false - Run tests first (default)  │
  │ • true  - Skip tests, deploy now     │
  │                                      │
  │ Notify Slack (optional)              │
  │ • true  - Send Slack notification    │
  │ • false - No notification (default)  │
  └──────────────────────────────────────┘

═════════════════════════════════════════════════════════════════════════════

🔑 REQUIRED GITHUB SECRETS (14 Required, 1 Optional)
═════════════════════════════════════════════════════════════════════════════

AWS Configuration (3 secrets)
  ✓ AWS_ACCESS_KEY_ID              - AWS IAM Access Key
  ✓ AWS_SECRET_ACCESS_KEY          - AWS IAM Secret Key
  ✓ AWS_REGION                     - e.g., us-east-1

EC2 Configuration (5 secrets)
  ✓ EC2_HOST                       - EC2 Public IP or DNS
  ✓ EC2_USER                       - SSH User (ubuntu, ec2-user, etc.)
  ✓ SSH_PRIVATE_KEY                - EC2 Key Pair (.pem file content)
  ✓ SSH_PORT                       - SSH Port (default: 22)
  ✓ APP_DEPLOYMENT_PATH            - /home/ubuntu/flask-app

Database Configuration (5 secrets)
  ✓ DB_HOST                        - RDS Endpoint
  ✓ DB_USER                        - Database Username
  ✓ DB_PASSWORD                    - Database Password
  ✓ DB_NAME                        - Database Name
  ✓ DB_PORT                        - Port (default: 3306)

Application Configuration (1 secret)
  ✓ APP_SECRET_KEY                 - Flask Secret Key (generate: python -c 'import secrets; print(secrets.token_hex(32))')

Optional (1 secret)
  ○ SLACK_WEBHOOK_URL              - For Slack notifications

═════════════════════════════════════════════════════════════════════════════

⚙️ POWERSHELL SCRIPTS BREAKDOWN
═════════════════════════════════════════════════════════════════════════════

1. deploy.ps1 (Main Deployment Script)
   ──────────────────────────────────────
   Location: .github/scripts/deploy.ps1
   When: Called by CD workflow
   
   Functions:
   • Validates deployment parameters
   • Secures SSH private key
   • Creates remote deployment script
   • Uploads script to EC2 via SCP
   • Executes deployment via SSH
   • Monitors application startup
   • Performs health checks
   • Cleans up temporary files
   
   Key Steps on EC2:
   1. Create/backup deployment directory
   2. Git pull latest code
   3. Install Python dependencies
   4. Create/update .env configuration
   5. Setup systemd service
   6. Restart Flask application
   7. Verify service is running
   
   Exit Codes:
   • 0: Deployment successful
   • 1: Deployment failed

───────────────────────────────────────────

2. setup-secrets.ps1 (Secrets Configuration Helper)
   ────────────────────────────────────────────────
   Location: .github/scripts/setup-secrets.ps1
   When: Run manually by developer (one time)
   
   Functions:
   • Lists all required secrets
   • Provides instructions for each
   • Shows GitHub CLI commands
   • Explains web UI steps
   • Provides example script
   
   Usage:
   PowerShell> .\.github\scripts\setup-secrets.ps1

───────────────────────────────────────────

3. health-check.ps1 (Application Health Verification)
   ──────────────────────────────────────────────────
   Location: .github/scripts/health-check.ps1
   When: Called by CD workflow post-deployment
   
   Functions:
   • Attempts HTTP connection to app
   • Retries with configurable attempts
   • Handles timeout scenarios
   • Provides troubleshooting steps
   
   Parameters:
   • EC2_HOST: Application server IP
   • APP_PORT: Application port (default: 5000)
   • TIMEOUT_SECONDS: Connection timeout (default: 10)
   • MAX_RETRIES: Maximum retry attempts (default: 3)
   
   Exit Codes:
   • 0: Application healthy
   • 1: Application not responding

═════════════════════════════════════════════════════════════════════════════

📋 FILE LOCATIONS & PURPOSES
═════════════════════════════════════════════════════════════════════════════

Workflow Files:
  .github/workflows/ci.yml
  ├─ Purpose: Runs on every push and PR
  ├─ Tests: Python 3.9, 3.10, 3.11
  ├─ Runs: Linting, Security, Tests
  └─ Trigger CD: Auto on main branch if passes
  
  .github/workflows/cd.yml
  ├─ Purpose: Manual deployment to AWS EC2
  ├─ Trigger: workflow_dispatch (manual UI)
  ├─ Options: Target env, skip tests, slack notification
  └─ Result: Application deployed and restarted

Script Files:
  .github/scripts/deploy.ps1
  ├─ Purpose: Main deployment logic
  ├─ Language: PowerShell
  ├─ Method: SSH to EC2
  └─ Result: Application running on EC2
  
  .github/scripts/setup-secrets.ps1
  ├─ Purpose: Configure GitHub Secrets
  ├─ Language: PowerShell
  └─ Action: Interactive configuration helper
  
  .github/scripts/health-check.ps1
  ├─ Purpose: Verify application is running
  ├─ Language: PowerShell
  └─ Action: HTTP endpoint verification

Documentation Files:
  CI-CD-SETUP.md
  ├─ Purpose: Complete setup and customization guide
  ├─ Audience: Developers and DevOps
  └─ Content: Secrets, customization, troubleshooting
  
  .github/DEPLOYMENT_GUIDE.md
  ├─ Purpose: Detailed deployment instructions
  ├─ Audience: First-time deployers
  └─ Content: Steps, monitoring, rollback
  
  QUICK-REFERENCE.md
  ├─ Purpose: Quick start and common tasks
  ├─ Audience: Regular users
  └─ Content: Quick steps, common commands
  
  .env.example
  ├─ Purpose: Template for environment variables
  └─ Usage: Copy to .env and fill with values
  
  .gitignore
  ├─ Purpose: Prevent accidental secret commits
  └─ Includes: .env, .pem files, __pycache__, etc.

Test Files:
  tests/test_app.py
  ├─ Purpose: Basic application tests
  ├─ Framework: pytest
  └─ Tests: Structure, imports, dependencies

═════════════════════════════════════════════════════════════════════════════

🚀 QUICK START CHECKLIST
═════════════════════════════════════════════════════════════════════════════

PREPARATION:
  ☐ Gather AWS credentials (Access Key, Secret Key, Region)
  ☐ Gather EC2 details (IP/DNS, SSH user, SSH key)
  ☐ Gather RDS details (endpoint, credentials, port)
  ☐ Generate Flask secret key: python -c 'import secrets; print(secrets.token_hex(32))'
  ☐ Prepare GitHub repository

CONFIGURATION:
  ☐ Push .github/ folder to repository
  ☐ Configure GitHub Secrets (14 required + 1 optional)
    Using: .github/scripts/setup-secrets.ps1
    Or: GitHub Web UI
    Or: GitHub CLI
  ☐ Verify all secrets are configured
  ☐ Create tests/ folder if needed

DEPLOYMENT:
  ☐ Push code to main branch
  ☐ Watch CI workflow run in Actions tab
  ☐ Verify CI passes
  ☐ Wait for CD to auto-trigger
  ☐ Monitor CD deployment
  ☐ Verify application is running
  ☐ Test application: curl http://your-ec2-ip:5000

VERIFICATION:
  ☐ Application responding at EC2 IP:5000
  ☐ Database connected (check logs)
  ☐ All features working
  ☐ Check deployment logs in GitHub Actions

═════════════════════════════════════════════════════════════════════════════

📊 MONITORING & MAINTENANCE
═════════════════════════════════════════════════════════════════════════════

Monitor CI/CD:
  • GitHub Actions tab → Check workflow runs
  • Detailed logs available for each step
  • Email notifications on failure

Monitor Application:
  • SSH into EC2
  • journalctl -u flask-app.service -f
  • Check /var/log/flask-app/app.log
  • Systemctl status flask-app.service

Monitor AWS:
  • EC2 dashboard for instance health
  • RDS dashboard for database health
  • Security Groups for network rules
  • CloudWatch for metrics

═════════════════════════════════════════════════════════════════════════════

🔒 SECURITY CHECKLIST
═════════════════════════════════════════════════════════════════════════════

Before Production Deployment:
  ☐ All secrets configured in GitHub
  ☐ SSH keys secured (not shared)
  ☐ EC2 security group restricts access
  ☐ RDS security group restricts access
  ☐ IAM user has minimal permissions
  ☐ Flask secret key is strong
  ☐ Database password is strong
  ☐ .env file in .gitignore
  ☐ No secrets in logs
  ☐ HTTPS configured (if applicable)
  ☐ Regular security updates

═════════════════════════════════════════════════════════════════════════════

✅ NEXT STEPS
═════════════════════════════════════════════════════════════════════════════

1. Read QUICK-REFERENCE.md for quick start
2. Run .github/scripts/setup-secrets.ps1 to configure secrets
3. Push code to main branch
4. Monitor CI/CD in GitHub Actions
5. Verify application runs on EC2
6. Read CI-CD-SETUP.md for advanced configuration

═════════════════════════════════════════════════════════════════════════════

📞 SUPPORT & TROUBLESHOOTING
═════════════════════════════════════════════════════════════════════════════

Check Detailed Guides:
  • CI-CD-SETUP.md - Complete setup and troubleshooting
  • .github/DEPLOYMENT_GUIDE.md - Deployment issues
  • QUICK-REFERENCE.md - Common tasks

Common Issues:
  • CI Fails → Check Python imports and dependencies
  • CD SSH Fails → Verify EC2_HOST, SSH key, security group
  • App Won't Start → Check database connection, env vars
  • Health Check Fails → Check port 5000, firewall rules

═════════════════════════════════════════════════════════════════════════════

Version: 1.0
Created: August 2024
Status: Ready for Deployment ✓

═════════════════════════════════════════════════════════════════════════════
```
