# CI/CD Deployment Guide

This guide explains how to use the GitHub Actions CI/CD pipeline to automatically test and deploy your Flask application to AWS EC2.

## 📋 Pipeline Overview

### Two-Stage Pipeline:

1. **CI (Continuous Integration)** - `.github/workflows/ci.yml`
   - Triggered on: `push` to `main` or `develop` branches, or `pull_request`
   - Tests Python versions: 3.9, 3.10, 3.11
   - Runs linting, security checks, and tests
   - Auto-triggers CD workflow when CI passes on `main` branch

2. **CD (Continuous Deployment)** - `.github/workflows/cd.yml`
   - Triggered manually via GitHub UI (Workflow Dispatch)
   - Allows selecting deployment target (staging/production)
   - Connects to EC2 via SSH
   - Deploys application and restarts service
   - Optional Slack notifications

---

## 🔑 Required GitHub Secrets

Configure these secrets in your GitHub repository for CI/CD to work:

### AWS Credentials
- `AWS_ACCESS_KEY_ID` - AWS IAM Access Key
- `AWS_SECRET_ACCESS_KEY` - AWS IAM Secret Key  
- `AWS_REGION` - AWS Region (e.g., `us-east-1`)

### EC2 Configuration
- `EC2_HOST` - EC2 Public IP or DNS name
- `EC2_USER` - SSH User (usually `ubuntu` or `ec2-user`)
- `SSH_PRIVATE_KEY` - EC2 Key Pair (PEM format)
- `SSH_PORT` - SSH Port (default: `22`)
- `APP_DEPLOYMENT_PATH` - Deployment path (default: `/home/ubuntu/flask-app`)

### Database Configuration
- `DB_HOST` - AWS RDS endpoint
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password
- `DB_NAME` - Database name
- `DB_PORT` - Database port (default: `3306`)

### Application Configuration
- `APP_SECRET_KEY` - Flask secret key (generate with `python -c 'import secrets; print(secrets.token_hex(32))'`)

### Optional
- `SLACK_WEBHOOK_URL` - Slack webhook for deployment notifications

---

## 🚀 How to Setup

### Step 1: Prepare Your EC2 Instance

Connect to your EC2 instance and install dependencies:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install -y python3 python3-pip python3-venv git

# Create deployment directory
mkdir -p /home/ubuntu/flask-app
cd /home/ubuntu/flask-app

# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .
```

### Step 2: Generate GitHub Secrets

**Option A: Using PowerShell Script (Windows)**
```powershell
.\.github\scripts\setup-secrets.ps1
```

**Option B: Manual Setup via GitHub Web UI**

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret from the list above

**Option C: Using GitHub CLI**
```bash
gh auth login
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_VALUE" -R owner/repo-name
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_VALUE" -R owner/repo-name
# ... repeat for all secrets
```

### Step 3: Push Your Code

```bash
git add .
git commit -m "Add CI/CD workflows"
git push origin main
```

---

## 🎯 Running the Pipeline

### Automatic Deployment (CI → CD)

1. Push code to `main` branch
2. CI workflow runs automatically
3. If CI passes, CD workflow triggers automatically
4. Application deploys to EC2

### Manual Deployment

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **CD - Deploy to AWS EC2** workflow
4. Click **Run workflow**
5. Select options:
   - **Deploy Target**: `staging` or `production`
   - **Skip Tests**: `true` or `false`
   - **Notify Slack**: `true` or `false` (if webhook configured)
6. Click **Run workflow**

---

## 📊 Monitoring Deployments

### View Logs in GitHub Actions

1. Go to **Actions** tab
2. Click the workflow run
3. Click the job to see detailed logs

### View Application Logs on EC2

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# View Flask app logs
sudo journalctl -u flask-app.service -f

# Or check log file
tail -f /var/log/flask-app/app.log
```

### Check Application Status

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Check service status
sudo systemctl status flask-app.service

# Restart service if needed
sudo systemctl restart flask-app.service

# Restart and check logs
sudo systemctl restart flask-app.service && sudo journalctl -u flask-app.service -f
```

---

## 🛠️ Customization

### Change Deployment Trigger

Edit `.github/workflows/cd.yml` to change when deployments trigger:

```yaml
on:
  # Push-based (auto-deploy on push to main)
  push:
    branches: [main]
  
  # Or keep workflow_dispatch (manual only)
  workflow_dispatch:
```

### Add More Test Environments

Edit `.github/workflows/ci.yml` to test additional Python versions:

```yaml
strategy:
  matrix:
    python-version: ['3.9', '3.10', '3.11', '3.12']
```

### Modify Deployment Path

Edit `.github/workflows/cd.yml` and update:

```yaml
APP_DEPLOYMENT_PATH = "/var/www/flask-app"
```

### Add Pre-deployment Health Check

Edit `.github/scripts/deploy.ps1` to add custom health checks.

---

## ❌ Troubleshooting

### CI Fails with Import Errors
- Ensure all dependencies in `requirements.txt` are correct
- Check Python version compatibility

### CD Fails - SSH Connection Error
- Verify `EC2_HOST` is correct
- Check `SSH_PRIVATE_KEY` is properly formatted
- Ensure EC2 security group allows SSH (port 22)
- Verify `EC2_USER` matches your instance type

### CD Fails - Deployment Script Error
- SSH into EC2 and check logs:
  ```bash
  sudo journalctl -u flask-app.service -n 50
  ```
- Verify database credentials in `.env`
- Ensure RDS database is accessible from EC2

### Service Won't Start
- Check if port 5000 is already in use
- Verify all environment variables are set
- Check database connection

### Health Check Fails
- Verify application is actually running
- Check firewall rules
- Ensure Flask is listening on correct port

---

## 📝 Advanced Features

### Slack Notifications

1. Create Slack Webhook URL
2. Add `SLACK_WEBHOOK_URL` secret
3. Run workflow with `Notify Slack` option enabled

### Roll Back to Previous Deployment

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Navigate to backup
cd /home/ubuntu/flask-app/backups
ls -la

# Restore from backup
cp -r backup_YYYYMMDD_HHMMSS/* /home/ubuntu/flask-app/

# Restart service
sudo systemctl restart flask-app.service
```

### Environment-Specific Deployments

The CD workflow supports staging and production:
- Both use same code, different database/configuration
- Customize per environment in deployment script

---

## 🔒 Security Best Practices

1. **Never commit secrets** - Use GitHub Secrets only
2. **Rotate access keys** regularly
3. **Use IAM roles** instead of access keys where possible
4. **Restrict EC2 security group** to known IPs
5. **Keep SSH keys secure** - Don't share `.pem` files
6. **Use strong passwords** for database
7. **Enable 2FA** on GitHub account

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [SSH Keys in GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## 🆘 Getting Help

If workflows fail:

1. Check detailed logs in GitHub Actions
2. Verify all secrets are configured correctly
3. Test SSH connection manually to EC2
4. Verify database connectivity
5. Check EC2 instance resources (disk space, memory)

---

**Last Updated**: 2024
**Version**: 1.0
