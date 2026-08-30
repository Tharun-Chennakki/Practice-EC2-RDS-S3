#!/bin/bash

##############################################################################
# 🚀 EC2 INITIAL SETUP SCRIPT
# Run this ONCE on your EC2 instance to prepare for automated deployments
# 
# Usage:
#   curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/.github/scripts/ec2-initial-setup.sh
#   chmod +x ec2-initial-setup.sh
#   ./ec2-initial-setup.sh
##############################################################################

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

##############################################################################
# STEP 1: Update system packages
##############################################################################
log_info "========================================="
log_info "EC2 Initial Setup - Flask Application"
log_info "========================================="
log_info "Step 1: Updating system packages..."

sudo apt-get update -y
sudo apt-get upgrade -y

log_success "System packages updated"

##############################################################################
# STEP 2: Install required dependencies
##############################################################################
log_info "Step 2: Installing required dependencies..."

sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    nano \
    vim \
    systemctl

log_success "Dependencies installed"

##############################################################################
# STEP 3: Create application directory
##############################################################################
log_info "Step 3: Creating application directory..."

APP_PATH="/home/ubuntu/flask-app"
if [ -d "$APP_PATH" ]; then
    log_warning "Directory $APP_PATH already exists"
else
    mkdir -p "$APP_PATH"
    chmod 755 "$APP_PATH"
    log_success "Directory created: $APP_PATH"
fi

##############################################################################
# STEP 4: Create log directory
##############################################################################
log_info "Step 4: Setting up log directory..."

sudo mkdir -p /var/log/flask-app
sudo chown ubuntu:ubuntu /var/log/flask-app
sudo chmod 755 /var/log/flask-app

log_success "Log directory created: /var/log/flask-app"

##############################################################################
# STEP 5: Initialize git repository (if not already done)
##############################################################################
log_info "Step 5: Initializing git repository..."

cd "$APP_PATH"

if [ -d ".git" ]; then
    log_warning "Git repository already exists"
    git fetch origin
    git reset --hard origin/main
else
    log_info "Cloning repository from GitHub..."
    # Note: User will need to update the repository URL
    log_warning "⚠️  Please clone your repository manually:"
    log_warning "   cd $APP_PATH"
    log_warning "   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ."
fi

##############################################################################
# STEP 6: Create Python virtual environment
##############################################################################
log_info "Step 6: Creating Python virtual environment..."

if [ -d "venv" ]; then
    log_warning "Virtual environment already exists"
else
    python3 -m venv venv
    log_success "Virtual environment created"
fi

# Activate venv and install initial dependencies
source venv/bin/activate
pip install --upgrade pip wheel setuptools
log_success "Python environment ready"

##############################################################################
# STEP 7: Create systemd service file template
##############################################################################
log_info "Step 7: Creating systemd service template..."

sudo tee /etc/systemd/system/flask-app.service > /dev/null << 'EOF'
[Unit]
Description=Flask Web Application
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/flask-app
Environment="PATH=/home/ubuntu/flask-app/venv/bin"
ExecStart=/home/ubuntu/flask-app/venv/bin/python app.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/flask-app/app.log
StandardError=append:/var/log/flask-app/error.log

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
log_success "Systemd service configured"

##############################################################################
# STEP 8: Create .env template
##############################################################################
log_info "Step 8: Creating .env template..."

cat > "$APP_PATH/.env.template" << 'EOF'
# Database Configuration
DB_HOST=your-rds-endpoint.amazonaws.com
DB_PORT=3306
DB_NAME=flask_db
DB_USER=admin
DB_PASSWORD=your-secure-password

# Flask Configuration
FLASK_ENV=production
FLASK_APP=app.py
FLASK_SECRET_KEY=generate-secure-key

# AWS S3 Configuration (Optional)
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_REGION=us-east-1
S3_BUCKET_NAME=your-bucket

# Deployment Information
DEPLOYMENT_ID=pending
DEPLOYMENT_TIMESTAMP=pending
DEPLOYMENT_ACTOR=pending
DEPLOYMENT_COMMIT=pending
EOF

log_success ".env template created at: $APP_PATH/.env.template"

##############################################################################
# STEP 9: Configure GitHub SSH access (optional)
##############################################################################
log_info "Step 9: Configuring SSH for GitHub..."

if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    log_success "SSH directory created"
else
    log_warning "SSH directory already exists"
fi

log_info "Configure SSH key: Copy your GitHub deploy key to ~/.ssh/github_key"
log_info "Then run: ssh-keyscan github.com >> ~/.ssh/known_hosts"

##############################################################################
# STEP 10: Display next steps
##############################################################################
log_info "========================================="
log_success "✓ EC2 INITIAL SETUP COMPLETED"
log_info "========================================="
log_info ""
log_info "📋 NEXT STEPS:"
log_info "1. Clone your repository:"
log_info "   cd /home/ubuntu/flask-app"
log_info "   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ."
log_info ""
log_info "2. Add your .env file:"
log_info "   cd /home/ubuntu/flask-app"
log_info "   nano .env"
log_info "   (Copy values from .env.template)"
log_info ""
log_info "3. Install dependencies:"
log_info "   source venv/bin/activate"
log_info "   pip install -r requirements.txt"
log_info ""
log_info "4. Test the application:"
log_info "   python app.py"
log_info ""
log_info "5. Start the service:"
log_info "   sudo systemctl start flask-app.service"
log_info ""
log_info "6. Check status:"
log_info "   systemctl status flask-app.service"
log_info ""
log_info "7. View logs:"
log_info "   tail -f /var/log/flask-app/app.log"
log_info ""
log_info "📌 After setup, use GitHub Actions to deploy:"
log_info "   - Push code → CI runs automatically"
log_info "   - Click 'Run workflow' in GitHub Actions → CD deploys to EC2"
log_info "   - No more manual SSH commands needed! 🚀"
log_info "========================================="
