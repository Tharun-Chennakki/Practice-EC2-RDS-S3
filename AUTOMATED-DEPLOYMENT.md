# 🚀 Automated CI/CD Deployment Guide

Complete guide to deploy your Flask app to AWS EC2 with **ONE CLICK** using GitHub Actions!

---

## 📋 Overview

```
┌─────────────────────────────────┐
│ You Push Code to GitHub         │
│ git push origin main            │
└──────────────┬──────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ ✅ CI RUNS AUTOMATICALLY         │
│ - Tests your code               │
│ - Checks for errors             │
│ - Validates dependencies        │
└──────────────┬───────────────────┘
               │
        ┌──────▼──────┐
        │ Pass? ✓     │
        └──────┬──────┘
               │
               ▼
┌──────────────────────────────────┐
│ 🎯 CD READY FOR DEPLOYMENT      │
│ (Click "Run workflow" button)    │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ 🚀 AUTOMATIC DEPLOYMENT TO EC2  │
│ - Pulls latest code             │
│ - Installs dependencies         │
│ - Creates .env with secrets     │
│ - Starts/restarts app service  │
│ - Verifies app is running       │
└──────────────┬───────────────────┘
               │
               ▼
        ✅ LIVE ON AWS EC2
```

---

## 🔧 PREREQUISITE: ONE-TIME EC2 SETUP

You only need to do this **ONCE** when you first get your EC2 instance:

### Step 1: SSH into your EC2 instance

```bash
ssh -i your-key-pair.pem ec2-user@your-ec2-ip
# OR
ssh -i your-key-pair.pem ubuntu@your-ec2-ip
```

### Step 2: Run the initial setup script

```bash
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/.github/scripts/ec2-initial-setup.sh
chmod +x ec2-initial-setup.sh
./ec2-initial-setup.sh
```

This script will:
- ✅ Update system packages
- ✅ Install Python, Git, and dependencies
- ✅ Create `/home/ubuntu/flask-app` directory
- ✅ Set up log directory
- ✅ Create systemd service for Flask app
- ✅ Create `.env` template

### Step 3: Clone your repository

```bash
cd /home/ubuntu/flask-app
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .
```

### Step 4: Test manual start (optional)

```bash
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

**Now your EC2 is ready! No more manual commands needed!** 🎉

---

## ✅ GITHUB SETUP (ONE-TIME)

### Step 1: Verify all secrets are added

Go to: **GitHub Repository** → **Settings** → **Secrets and variables** → **Actions**

Make sure these secrets exist:
- `APP_SECRET_KEY` ✓
- `AWS_ACCESS_KEY_ID` ✓
- `AWS_SECRET_ACCESS_KEY` ✓
- `AWS_REGION` ✓
- `DB_HOST` ✓
- `DB_NAME` ✓
- `DB_PASSWORD` ✓
- `DB_PORT` ✓
- `DB_USER` ✓
- `EC2_HOST` (Your EC2 public IP) ✓
- `EC2_USER` (ubuntu or ec2-user) ✓
- `SSH_PRIVATE_KEY` (Your EC2 key pair in PEM format) ✓
- `SSH_PORT` (Usually 22) ✓
- `APP_DEPLOYMENT_PATH` (/home/ubuntu/flask-app) ✓

All your secrets are visible in the screenshot you shared! ✅

---

## 🚀 AUTOMATED DEPLOYMENT WORKFLOW

### Option 1: Automatic Deployment (Recommended)

This is the **EASIEST** way:

#### Step 1: Update your code locally
```bash
# Make changes to your app
# e.g., modify app.py, add new features, etc.
```

#### Step 2: Commit and push to GitHub
```bash
git add .
git commit -m "Add new feature or fix"
git push origin main
```

#### Step 3: Watch CI run automatically
- Go to **GitHub** → **Actions** tab
- You'll see the CI workflow running
- It will test your code
- If tests pass ✅, CD workflow is triggered

#### Step 4: Watch CD deploy automatically
- The CD workflow will automatically start (if on main branch)
- It will deploy to your EC2 instance
- Watch the logs in real-time
- Your app is now live! 🚀

---

### Option 2: Manual Deployment from GitHub UI

If you want to manually trigger deployment:

#### Step 1: Commit your code
```bash
git add .
git commit -m "Your message"
git push origin main
```

#### Step 2: Go to GitHub Actions
1. Open your GitHub repository
2. Click the **Actions** tab
3. On the left, select **CD - Deploy to AWS EC2**

#### Step 3: Click "Run workflow"
1. Click the **Run workflow** button (green button on the right)
2. A dropdown will appear with options:

```
Deploy target: [staging ▼]
Skip tests: [false ▼]
Notify Slack: [false ▼]
```

3. Select your options:
   - **Deploy target**: Choose `staging` or `production`
   - **Skip tests**: Choose `false` to run tests first
   - **Notify Slack**: Choose `false` (unless you have Slack setup)

4. Click the green **Run workflow** button

#### Step 4: Monitor deployment
- You'll see real-time logs as the deployment happens
- Green checkmarks = success ✅
- Red X = failed ❌

---

## 📊 Deployment Process (What happens automatically)

When the CD workflow runs, it will:

1. **Pre-Deployment Checks**
   - Generate deployment ID
   - Validate configuration
   - Show deployment details

2. **Run Tests** (if enabled)
   - Execute pytest
   - Verify no breaking changes

3. **Deploy to EC2**
   - SSH into your EC2 instance
   - Pull latest code from GitHub
   - Create/update `.env` file with secrets
   - Install dependencies: `pip install -r requirements.txt`
   - Create systemd service
   - Start/restart Flask app
   - Verify app is running

4. **Health Check**
   - Pings `http://EC2_IP:5000/health`
   - Confirms app is working
   - Database connectivity check

5. **Completion**
   - Shows success/failure status
   - Displays logs
   - (Optional) Send Slack notification

---

## 📱 How It Looks in GitHub

### Actions Tab - Workflow List
```
✅ CI - Build & Test          (Last run: 2 minutes ago)
✅ CD - Deploy to AWS EC2     (Last run: 5 minutes ago)
```

### When you click "Run workflow"
```
┌─────────────────────────────────────────┐
│ This workflow has a workflow_dispatch    │
│ event trigger                           │
├─────────────────────────────────────────┤
│ Deploy target *                         │
│ [staging ▼]                             │
│                                         │
│ Skip tests *                            │
│ [false ▼]                               │
│                                         │
│ Notify Slack *                          │
│ [false ▼]                               │
├─────────────────────────────────────────┤
│ [Run workflow]                          │
└─────────────────────────────────────────┘
```

### During Deployment
```
🟢 pre-deployment-checks        ✓ Passed
🟢 run-tests                    ✓ Passed
🟡 deploy-to-aws                ⏳ In progress
  - Checkout code               ✓
  - Configure AWS credentials   ✓
  - Deploy application via SSH  ⏳
    > Connecting to EC2...
    > Pulling latest code...
    > Installing dependencies...
    > Restarting Flask app...
```

---

## ✨ Verify Deployment Success

After deployment completes:

### Check 1: GitHub Actions shows success
- Go to Actions → CD workflow
- Final status shows: ✅ DEPLOYMENT SUCCESSFUL

### Check 2: Access your app
```
Open browser: http://your-ec2-ip:5000
You should see the login page
```

### Check 3: Check health endpoint
```
http://your-ec2-ip:5000/health
```

Response should look like:
```json
{
  "status": "healthy",
  "application": "Flask Web Application",
  "version": "1.0.0",
  "timestamp": "2026-08-31T10:30:45.123456",
  "database": "connected"
}
```

### Check 4: SSH into EC2 and verify service (optional)
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
systemctl status flask-app.service
# Output: active (running) ✓

# View logs:
tail -f /var/log/flask-app/app.log
```

---

## 🆘 Troubleshooting

### "Deployment failed" in GitHub Actions

1. **Check the logs**: Click on the failed job to see error messages
2. **Common issues**:
   - SSH key not working → Verify `SSH_PRIVATE_KEY` secret is correct
   - Database not accessible → Check `DB_HOST` and credentials
   - Python not found → EC2 setup script didn't run
   - Port 5000 already in use → Kill existing process

### "Health check failed after 5 attempts"

This means the Flask app didn't start within 25 seconds (5 x 5 second retries).

Check EC2 logs:
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
journalctl -u flask-app.service -n 50
tail -f /var/log/flask-app/error.log
```

### "Connection refused"

Your EC2 might not have the security group rule open for port 5000:

1. Go to AWS EC2 console
2. Select your instance
3. Click "Security" tab
4. Click security group link
5. Add inbound rule:
   - Type: Custom TCP
   - Port: 5000
   - Source: Your IP or 0.0.0.0/0 (not recommended for production)

---

## 📝 Workflow Files

Your CI/CD setup uses these files:

```
.github/
├── workflows/
│   ├── ci.yml              ← Runs tests automatically on push
│   └── cd.yml              ← Deploys to EC2 (manual or auto)
├── scripts/
│   ├── deploy.ps1          ← PowerShell deployment script
│   ├── ec2-initial-setup.sh ← One-time EC2 setup
│   └── setup-secrets.ps1   ← Helper for GitHub secrets
└── DEPLOYMENT_GUIDE.md     ← This file
```

---

## 🎯 Next Steps

1. ✅ Verify all GitHub secrets are set
2. ✅ Run EC2 initial setup (one-time)
3. ✅ Push code to main branch
4. ✅ Go to GitHub Actions
5. ✅ Click "Run workflow" on CD
6. ✅ Watch deployment happen automatically
7. ✅ Access your app at `http://EC2_IP:5000`

---

## 💡 Pro Tips

1. **Add S3 integration later**: The secrets are already configured, just update deploy.ps1
2. **Slack notifications**: Add `SLACK_WEBHOOK_URL` secret, then enable in workflow
3. **Production ready**: For production, use `deploy_target: production`
4. **Zero-downtime**: The script stops old service and starts new one
5. **Automatic restarts**: If app crashes, systemd will restart it automatically

---

## 📞 Support

If something doesn't work:
1. Check GitHub Actions logs
2. SSH into EC2 and check systemd logs
3. Verify all secrets are correct
4. Ensure EC2 has internet access
5. Check security group allows port 5000

Happy deploying! 🚀

