# 🚀 GitHub Actions CI/CD Pipeline Setup

Complete CI/CD pipeline for Flask application deployed to AWS EC2 with AWS RDS MySQL.

## 📂 Project Structure

```
.github/
├── workflows/
│   ├── ci.yml              # Continuous Integration workflow
│   └── cd.yml              # Continuous Deployment workflow
└── scripts/
    ├── deploy.ps1          # PowerShell deployment script
    ├── setup-secrets.ps1   # PowerShell script to configure secrets
    └── health-check.ps1    # (Optional) Health check script

tests/
└── test_app.py            # Basic application tests

.env.example               # Environment variables template
.gitignore                 # Git ignore rules
DEPLOYMENT_GUIDE.md        # Detailed deployment guide
CI-CD-SETUP.md            # This file
```

---

## 🎯 Quick Start

### 1️⃣ **Prepare Your EC2 Instance**

SSH into your EC2 instance and run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git

mkdir -p /home/ubuntu/flask-app
cd /home/ubuntu/flask-app
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .
```

### 2️⃣ **Configure GitHub Secrets**

Run PowerShell setup script (Windows):
```powershell
.\.github\scripts\setup-secrets.ps1
```

Or manually via GitHub UI:
- Go to **Settings** → **Secrets and variables** → **Actions**
- Add all required secrets (see below)

### 3️⃣ **Push Your Code**

```bash
git add .
git commit -m "Add CI/CD workflows"
git push origin main
```

### 4️⃣ **Monitor & Deploy**

- **Automatic**: CI runs on push, auto-deploys CD on `main` branch
- **Manual**: Go to Actions → "CD - Deploy to AWS EC2" → Run workflow

---

## 🔑 Required Secrets

| Secret Name | Example Value | Description |
|-------------|---------------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | AWS IAM access key |
| `AWS_SECRET_ACCESS_KEY` | `wJal...` | AWS IAM secret key |
| `AWS_REGION` | `us-east-1` | AWS region |
| `EC2_HOST` | `54.123.45.67` | EC2 public IP or DNS |
| `EC2_USER` | `ubuntu` | SSH username (ubuntu/ec2-user) |
| `SSH_PRIVATE_KEY` | `-----BEGIN RSA PRIVATE KEY-----...` | EC2 key pair (PEM format) |
| `SSH_PORT` | `22` | SSH port |
| `APP_DEPLOYMENT_PATH` | `/home/ubuntu/flask-app` | App deployment directory |
| `DB_HOST` | `mysql...rds.amazonaws.com` | RDS endpoint |
| `DB_USER` | `admin` | Database username |
| `DB_PASSWORD` | `SecurePass123!` | Database password |
| `DB_NAME` | `flask_db` | Database name |
| `DB_PORT` | `3306` | Database port |
| `APP_SECRET_KEY` | `a1b2c3d4...` | Flask secret (generate) |
| `SLACK_WEBHOOK_URL` | `https://hooks.slack.com/...` | (Optional) Slack notifications |

### Generate Flask Secret Key

```bash
python -c 'import secrets; print(secrets.token_hex(32))'
```

---

## 📊 Workflow Overview

### CI Workflow (`.github/workflows/ci.yml`)

**Triggers**: `push` to main/develop, `pull_request`

**Steps**:
1. Checkout code
2. Setup Python (3.9, 3.10, 3.11)
3. Install dependencies
4. Run linting (flake8)
5. Check code formatting (black)
6. Security checks (bandit)
7. Run tests (pytest)
8. Check for vulnerabilities (safety)
9. Auto-trigger CD on `main` branch

**Duration**: ~3-5 minutes per Python version

### CD Workflow (`.github/workflows/cd.yml`)

**Triggers**: Manual via GitHub UI (workflow_dispatch)

**Inputs**:
- **Deploy Target**: `staging` or `production`
- **Skip Tests**: `true` or `false`
- **Notify Slack**: `true` or `false`

**Steps**:
1. Pre-deployment checks
2. (Optional) Run tests
3. Deploy via SSH to EC2
4. Setup environment variables
5. Install dependencies
6. Create systemd service
7. Restart Flask app
8. Health check
9. (Optional) Slack notification

**Duration**: ~2-3 minutes

---

## 🚀 Manual Deployment Steps

### Via GitHub Actions UI (Recommended)

1. Go to **Actions** tab
2. Select **"CD - Deploy to AWS EC2"** workflow
3. Click **Run workflow** dropdown
4. Fill in options:
   - **Use workflow from**: `main`
   - **Deploy target**: `staging` or `production`
   - **Skip tests**: `false` (recommended)
   - **Notify Slack**: `true` (if configured)
5. Click **Run workflow**
6. Monitor deployment in real-time

### Via GitHub CLI

```bash
gh workflow run cd.yml -f deploy_target=production -f skip_tests=false
```

### Via PowerShell Script (Advanced)

Create custom deployment script using `.github/scripts/deploy.ps1`:

```powershell
$params = @{
    EC2_HOST = "your-ec2-ip"
    EC2_USER = "ubuntu"
    SSH_PRIVATE_KEY = Get-Content "path/to/key.pem" -Raw
    ENVIRONMENT = "production"
    DB_HOST = "your-rds-host"
    # ... add other parameters
}

& .\.github\scripts\deploy.ps1 @params
```

---

## 📋 Deployment Process Flow

```
┌─────────────────────────────────────────┐
│  Developer Pushes Code to GitHub        │
└────────────────┬────────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  CI Workflow   │
        │ - Tests Code   │
        │ - Linting      │
        │ - Security     │
        └────────┬───────┘
                 │
        ┌────────▼───────┐
        │  CI Passed?    │
        └────────┬───────┘
                 │
        ╔════════╩═══════════════════╗
        │                            │
    ╔═══▼════╗                  ╔═══▼════╗
    │ NO     │                  │ YES    │
    │ STOP   │                  │ ✓      │
    ╚════════╝          ┌───────▼────────┐
                        │  Trigger CD    │
                        │  Workflow      │
                        │  Automatically │
                        │ (main branch)  │
                        └────────┬───────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  Manual CD Trigger       │
                    │  via Actions UI or CLI   │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                        ┌────────────────┐
                        │  CD Workflow   │
                        │ - SSH Connect  │
                        │ - Git Pull     │
                        │ - Install Deps │
                        │ - Setup Env    │
                        │ - Restart App  │
                        │ - Health Check │
                        └────────┬───────┘
                                 │
                    ┌────────────▼──────────┐
                    │  Deployment Complete  │
                    │  App Running on EC2   │
                    └───────────────────────┘
```

---

## 🔍 Monitoring & Logs

### View GitHub Actions Logs

1. Go to **Actions** tab
2. Click the workflow run
3. Click job name to expand
4. View detailed step logs

### View EC2 Application Logs

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# View Flask application logs (live)
sudo journalctl -u flask-app.service -f

# View last 50 lines of logs
sudo journalctl -u flask-app.service -n 50

# View error logs
tail -f /var/log/flask-app/error.log

# View application logs
tail -f /var/log/flask-app/app.log
```

### Check Service Status

```bash
# Check if Flask service is running
sudo systemctl status flask-app.service

# Restart the service
sudo systemctl restart flask-app.service

# Stop the service
sudo systemctl stop flask-app.service

# Start the service
sudo systemctl start flask-app.service

# Enable auto-start on reboot
sudo systemctl enable flask-app.service
```

### Test Application Manually

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Test connection to Flask app
curl http://localhost:5000

# Or from your local machine
curl http://your-ec2-ip:5000
```

---

## ⚙️ Customization

### Change CI Test Environments

Edit `.github/workflows/ci.yml`:

```yaml
strategy:
  matrix:
    python-version: ['3.9', '3.10', '3.11', '3.12']
```

### Change Deployment Trigger

Make CD auto-deploy on every push:

Edit `.github/workflows/cd.yml`, change `on:` section:

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
```

### Add Pre-deployment Approvals

Edit `.github/workflows/cd.yml`:

```yaml
deploy-to-aws:
  environment:
    name: production
    url: http://${{ secrets.EC2_HOST }}
```

### Skip CD Auto-trigger

Remove from `.github/workflows/ci.yml`:

```yaml
- name: Dispatch CD Workflow
  uses: actions/github-script@v7
  with: ...
```

### Customize Deployment Path

Edit `.github/scripts/deploy.ps1` and change:

```powershell
$APP_DEPLOYMENT_PATH = "/var/www/my-app"
```

---

## 🛠️ Troubleshooting

### CI Fails with Python Import Error

**Solution**:
1. Check `requirements.txt` has all dependencies
2. Verify dependencies are compatible
3. Run locally: `pip install -r requirements.txt`

### CD Fails - SSH Connection Refused

**Solution**:
1. Verify EC2 public IP is correct
2. Check security group allows SSH (port 22)
3. Verify SSH key is correct PEM format
4. Test locally: `ssh -i key.pem ubuntu@ip`

### CD Fails - Deployment Script Error

**Solution**:
1. SSH into EC2 and check logs:
   ```bash
   sudo journalctl -u flask-app.service -n 50
   tail -f /var/log/flask-app/error.log
   ```
2. Verify `.env` file is created with correct values
3. Check database connectivity from EC2

### Application Won't Start After Deployment

**Solution**:
```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Check service status
sudo systemctl status flask-app.service

# View detailed error logs
sudo journalctl -u flask-app.service -n 100

# Try running app manually
cd /home/ubuntu/flask-app
source venv/bin/activate
python app.py
```

### Database Connection Fails

**Solution**:
1. Verify RDS endpoint and credentials in secrets
2. Check RDS security group allows port 3306 from EC2
3. Test from EC2:
   ```bash
   mysql -h rds-endpoint -u username -p database_name
   ```
4. Verify RDS is in same VPC as EC2

---

## 📝 Best Practices

✅ **Do**:
- Use GitHub Secrets for all sensitive data
- Test locally before pushing
- Keep dependencies updated
- Monitor deployment logs
- Use descriptive commit messages
- Backup before major changes
- Use staging environment for testing
- Enable branch protection rules

❌ **Don't**:
- Commit secrets or `.env` files
- Use `root` for deployments
- Skip tests before deployment
- Keep default Flask secret key
- Deploy without health checks
- Ignore deployment errors
- Share SSH keys or PEM files

---

## 🔒 Security Checklist

- [ ] All secrets configured in GitHub
- [ ] SSH key stored securely (`.pem` not in repo)
- [ ] EC2 security group restricts SSH access
- [ ] RDS security group restricts database access
- [ ] IAM user has minimal required permissions
- [ ] Flask secret key is strong and unique
- [ ] Database password is strong
- [ ] `.env` file in `.gitignore`
- [ ] No secrets in logs or error messages
- [ ] HTTPS enabled (configure in Flask app)
- [ ] Regular security updates applied

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS EC2 Docs](https://docs.aws.amazon.com/ec2/)
- [AWS RDS Docs](https://docs.aws.amazon.com/rds/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [GitHub Secrets Guide](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

## 📞 Support

If you encounter issues:

1. Check GitHub Actions logs (detailed error messages)
2. SSH into EC2 and check application logs
3. Verify all GitHub Secrets are configured
4. Verify EC2 and RDS security groups
5. Test connectivity manually

---

**Version**: 1.0  
**Last Updated**: August 2024  
**Maintained By**: Your Team
