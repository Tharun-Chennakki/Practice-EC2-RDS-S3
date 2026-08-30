# 🚀 CI/CD Quick Reference Guide

## What Was Created

Your GitHub Actions CI/CD pipeline is ready! Here's what was set up:

### 📁 New Files Created

```
.github/
├── workflows/
│   ├── ci.yml              ✓ Continuous Integration (auto on push/PR)
│   └── cd.yml              ✓ Continuous Deployment (manual trigger)
├── scripts/
│   ├── deploy.ps1          ✓ Main deployment script (PowerShell)
│   ├── setup-secrets.ps1   ✓ Secrets configuration helper
│   └── health-check.ps1    ✓ Application health verification
└── DEPLOYMENT_GUIDE.md     ✓ Detailed deployment documentation

tests/
└── test_app.py             ✓ Basic test suite

CI-CD-SETUP.md              ✓ Complete setup guide
.github/DEPLOYMENT_GUIDE.md ✓ Deployment guide
```

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Get AWS Credentials Ready
You need:
- AWS Access Key ID
- AWS Secret Access Key
- AWS Region (e.g., us-east-1)

### Step 2: Get EC2 Details
- EC2 public IP or DNS name
- EC2 SSH username (ubuntu, ec2-user, etc.)
- EC2 SSH private key (.pem file)
- SSH port (usually 22)

### Step 3: Get RDS Details
- RDS endpoint
- Database name
- Database username
- Database password
- Database port (usually 3306)

### Step 4: Generate Flask Secret Key
```bash
python -c 'import secrets; print(secrets.token_hex(32))'
```

### Step 5: Configure GitHub Secrets

**Option A - PowerShell (Easiest)**
```powershell
.\.github\scripts\setup-secrets.ps1
```

**Option B - GitHub CLI**
```bash
gh auth login
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_VALUE"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_VALUE"
# ... continue for all secrets
```

**Option C - GitHub Web UI**
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret one by one

### Step 6: Push to GitHub
```bash
git add .github/ CI-CD-SETUP.md tests/
git commit -m "Add CI/CD pipelines"
git push origin main
```

### Step 7: Trigger Deployment

**Auto Deploy** (only on main branch):
- Just push to main, CI runs, then CD auto-deploys

**Manual Deploy**:
1. Go to Actions tab
2. Select "CD - Deploy to AWS EC2"
3. Click "Run workflow"
4. Select options and confirm

---

## 📋 All Required Secrets

Copy this checklist and fill in your values:

```
☐ AWS_ACCESS_KEY_ID = 
☐ AWS_SECRET_ACCESS_KEY = 
☐ AWS_REGION = us-east-1
☐ EC2_HOST = 
☐ EC2_USER = ubuntu
☐ SSH_PRIVATE_KEY = (copy entire .pem file)
☐ SSH_PORT = 22
☐ APP_DEPLOYMENT_PATH = /home/ubuntu/flask-app
☐ DB_HOST = 
☐ DB_USER = 
☐ DB_PASSWORD = 
☐ DB_NAME = 
☐ DB_PORT = 3306
☐ APP_SECRET_KEY = (generate: python -c 'import secrets; print(secrets.token_hex(32))')
☐ SLACK_WEBHOOK_URL = (optional)
```

---

## 🔄 How CI/CD Works

### When You Push Code

```
Push to main
    ↓
CI Workflow Starts (2-5 min)
├─ Install dependencies
├─ Run linting
├─ Run security checks
├─ Run tests
└─ If all pass → CD triggers
    ↓
CD Workflow Starts (2-3 min)
├─ SSH to EC2
├─ Git pull latest code
├─ Install Python dependencies
├─ Update .env configuration
├─ Restart Flask application
└─ Health check
    ↓
Application Deployed! ✓
```

### Manual Deployment

```
Click "Run workflow" in Actions
    ↓
Select options:
├─ Deploy Target (staging/production)
├─ Skip Tests (true/false)
└─ Notify Slack (true/false)
    ↓
CD Workflow Executes (2-3 min)
    ↓
Application Updated! ✓
```

---

## 📊 Files Explained

### `.github/workflows/ci.yml`
- **Purpose**: Test code on every push/PR
- **Triggers**: Push to main/develop, Pull Requests
- **Tests**: Python 3.9, 3.10, 3.11
- **Auto-deploys**: CD on main branch after passing

### `.github/workflows/cd.yml`
- **Purpose**: Deploy app to AWS EC2
- **Triggers**: Manual (workflow_dispatch)
- **Options**: Target env, skip tests, Slack notification
- **Steps**: SSH → Git pull → Install → Configure → Restart

### `.github/scripts/deploy.ps1`
- **Purpose**: Main deployment logic
- **Language**: PowerShell
- **Does**:
  - Connects to EC2 via SSH
  - Pulls latest code from GitHub
  - Installs Python dependencies
  - Creates .env file with secrets
  - Configures systemd service
  - Restarts Flask application

### `.github/scripts/setup-secrets.ps1`
- **Purpose**: Helper to configure GitHub Secrets
- **Language**: PowerShell
- **Does**: Explains all secrets needed and how to add them

### `.github/scripts/health-check.ps1`
- **Purpose**: Verify app is running after deployment
- **Language**: PowerShell
- **Does**: Tests HTTP connection with retries

### `tests/test_app.py`
- **Purpose**: Basic application tests
- **Framework**: pytest
- **Tests**: File structure, imports, requirements

---

## 🎯 Common Tasks

### Check Deployment Status
```
GitHub → Actions tab → Select workflow run
```

### View Application Logs
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
sudo journalctl -u flask-app.service -f
```

### Restart Application Manually
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
sudo systemctl restart flask-app.service
```

### Rollback to Previous Deployment
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
cd /home/ubuntu/flask-app/backups
ls -la  # Find backup
cp -r backup_YYYYMMDD_HHMMSS/* /home/ubuntu/flask-app/
sudo systemctl restart flask-app.service
```

### View CI/CD Logs Locally
```bash
git log --all --oneline
```

---

## 🐛 Troubleshooting

### CI Fails
**Check**:
- Python version compatibility
- All dependencies in requirements.txt
- Syntax errors in Python code

**Fix**:
```bash
pip install -r requirements.txt
pytest tests/
flake8 .
```

### CD Fails - SSH Error
**Check**:
- EC2_HOST is correct IP/DNS
- SSH key (.pem) format is correct
- EC2 security group allows port 22

**Fix**:
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip  # Test manually
```

### CD Fails - App Won't Start
**Check**:
- Database credentials are correct
- RDS is accessible from EC2
- No port conflicts on EC2

**Fix**:
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
sudo journalctl -u flask-app.service -n 50
tail -f /var/log/flask-app/error.log
```

### Health Check Fails
**Check**:
- Port 5000 is listening
- No firewall blocking port 5000

**Fix**:
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
sudo systemctl status flask-app.service
sudo netstat -tlnp | grep 5000
```

---

## 📞 Workflow Dispatch Inputs

When running CD manually, you can select:

### Deploy Target
- `staging`: Deploy to staging environment
- `production`: Deploy to production environment

### Skip Tests
- `false`: Run tests before deployment (recommended)
- `true`: Skip tests and deploy immediately

### Notify Slack
- `true`: Send Slack notification after deployment
- `false`: No Slack notification
- Requires: `SLACK_WEBHOOK_URL` secret configured

---

## 🔒 Important Security Notes

⚠️ **NEVER**:
- Commit `.env` files
- Share SSH private keys (.pem)
- Hardcode secrets in code
- Use weak passwords

✅ **ALWAYS**:
- Use GitHub Secrets for all sensitive data
- Rotate AWS access keys regularly
- Keep SSH keys secure
- Use strong, unique passwords
- Review GitHub Actions logs
- Monitor deployments

---

## 📚 Learn More

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [AWS EC2 Guide](https://docs.aws.amazon.com/ec2/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- See: `CI-CD-SETUP.md` for detailed guide
- See: `.github/DEPLOYMENT_GUIDE.md` for deployment details

---

## ✅ Verification Checklist

Before first deployment:

- [ ] All GitHub Secrets configured
- [ ] EC2 instance running and accessible
- [ ] RDS database running and accessible
- [ ] Python 3.x installed on EC2
- [ ] Git installed on EC2
- [ ] SSH key works: `ssh -i key.pem ubuntu@ec2-ip`
- [ ] Database credentials work: `mysql -h rds-host -u user -p db`
- [ ] Code pushed to GitHub main branch
- [ ] GitHub Actions enabled in repo

---

## 🚀 Next Steps

1. ✅ Configure all GitHub Secrets
2. ✅ Push code to GitHub
3. ✅ Wait for CI to pass
4. ✅ CD auto-deploys to EC2
5. ✅ Check application at http://your-ec2-ip:5000

**Done!** 🎉 Your Flask app is now on AWS with CI/CD!

---

**Questions?** Check detailed guides:
- `CI-CD-SETUP.md` - Complete setup guide
- `.github/DEPLOYMENT_GUIDE.md` - Deployment guide  
- `.github/workflows/ci.yml` - CI workflow details
- `.github/workflows/cd.yml` - CD workflow details

**Version**: 1.0  
**Last Updated**: August 2024
