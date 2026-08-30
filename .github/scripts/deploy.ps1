param(
    [string]$EC2_HOST,
    [string]$EC2_USER,
    [string]$SSH_PRIVATE_KEY,
    [string]$SSH_PORT = "22",
    [string]$APP_DEPLOYMENT_PATH = "/home/ubuntu/flask-app",
    [string]$ENVIRONMENT = "staging",
    [string]$DB_HOST,
    [string]$DB_USER,
    [string]$DB_PASSWORD,
    [string]$DB_NAME,
    [string]$DB_PORT = "3306",
    [string]$APP_SECRET_KEY,
    [string]$DEPLOYMENT_ID,
    [string]$GITHUB_ACTOR,
    [string]$GITHUB_SHA,
    [string]$GITHUB_REF
)

# Color codes for output
$GREEN = "`e[32m"
$RED = "`e[31m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$RESET = "`e[0m"

function Log-Info {
    param([string]$Message)
    Write-Host "$BLUE[INFO]$RESET $Message"
}

function Log-Success {
    param([string]$Message)
    Write-Host "$GREEN[SUCCESS]$RESET $Message"
}

function Log-Warning {
    param([string]$Message)
    Write-Host "$YELLOW[WARNING]$RESET $Message"
}

function Log-Error {
    param([string]$Message)
    Write-Host "$RED[ERROR]$RESET $Message"
}

# ============================================================================
# STEP 1: Validate parameters
# ============================================================================
Log-Info "========================================="
Log-Info "AWS EC2 Flask App Deployment Script"
Log-Info "========================================="
Log-Info "Deployment ID: $DEPLOYMENT_ID"
Log-Info "Environment: $ENVIRONMENT"
Log-Info "EC2 Host: $EC2_HOST"
Log-Info "EC2 User: $EC2_USER"
Log-Info "App Path: $APP_DEPLOYMENT_PATH"
Log-Info "========================================="

if (-not $EC2_HOST -or -not $EC2_USER -or -not $SSH_PRIVATE_KEY) {
    Log-Error "Missing required parameters!"
    Log-Error "Required: EC2_HOST, EC2_USER, SSH_PRIVATE_KEY"
    exit 1
}

# ============================================================================
# STEP 2: Setup SSH key
# ============================================================================
Log-Info "Setting up SSH credentials..."
$sshKeyPath = "$env:USERPROFILE\.ssh\github_actions_key"
$sshDir = Split-Path $sshKeyPath
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

# Write SSH key
$SSH_PRIVATE_KEY | Out-File -FilePath $sshKeyPath -Encoding ASCII -Force
icacls $sshKeyPath /inheritance:r /grant:r "${env:USERNAME}:F" | Out-Null
Log-Success "SSH key configured"

# ============================================================================
# STEP 3: Create deployment script for remote execution
# ============================================================================
Log-Info "Preparing remote deployment script..."

$remoteScript = @"
#!/bin/bash
set -e

export DEPLOYMENT_ID="$DEPLOYMENT_ID"
export ENVIRONMENT="$ENVIRONMENT"
export GITHUB_ACTOR="$GITHUB_ACTOR"
export GITHUB_SHA="$GITHUB_SHA"
export GITHUB_REF="$GITHUB_REF"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "\${BLUE}[INFO]\${NC} \$1"
}

log_success() {
  echo -e "\${GREEN}[SUCCESS]\${NC} \$1"
}

log_error() {
  echo -e "\${RED}[ERROR]\${NC} \$1"
}

log_warning() {
  echo -e "\${YELLOW}[WARNING]\${NC} \$1"
}

# ============================================================================
# REMOTE DEPLOYMENT STEPS
# ============================================================================

log_info "========================================="
log_info "Starting Deployment on EC2"
log_info "========================================="
log_info "Deployment ID: \$DEPLOYMENT_ID"
log_info "Environment: \$ENVIRONMENT"
log_info "Deployment started by: \$GITHUB_ACTOR"
log_info "Commit SHA: \$GITHUB_SHA"
log_info "Branch: \$GITHUB_REF"
log_info "========================================="

# Create deployment directory if it doesn't exist
log_info "Creating deployment directory..."
sudo mkdir -p "$APP_DEPLOYMENT_PATH"
sudo chown \$USER:\$USER "$APP_DEPLOYMENT_PATH"

# Navigate to deployment directory
cd "$APP_DEPLOYMENT_PATH"

# Create backup directory
BACKUP_DIR="backups/backup_\$(date +%Y%m%d_%H%M%S)"
log_info "Creating backup: \$BACKUP_DIR"
mkdir -p "\$BACKUP_DIR"

# Backup current deployment (if it exists)
if [ -f "app.py" ]; then
    log_info "Backing up current deployment..."
    cp -r . "\$BACKUP_DIR/" 2>/dev/null || true
    log_success "Backup created: \$BACKUP_DIR"
else
    log_warning "No existing deployment found (first deployment)"
fi

# Update application from GitHub
log_info "Updating application code from GitHub..."
if [ -d ".git" ]; then
    git fetch origin
    git reset --hard origin/\${GITHUB_REF##*/}
    git clean -fd
else
    log_warning "Git repository not found, assuming fresh clone"
fi

# Install/Update Python dependencies
log_info "Installing Python dependencies..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

log_success "Dependencies installed"

# Create/Update .env file with database credentials
log_info "Configuring environment variables..."
cat > .env << 'ENVEOF'
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
FLASK_ENV=$ENVIRONMENT
FLASK_APP=app.py
FLASK_SECRET_KEY=$APP_SECRET_KEY
FLASK_DEBUG=False
FLASK_HOST=0.0.0.0
FLASK_PORT=5000
DEPLOYMENT_ID=$DEPLOYMENT_ID
DEPLOYMENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DEPLOYMENT_ACTOR=$GITHUB_ACTOR
DEPLOYMENT_COMMIT=$GITHUB_SHA
ENVEOF

log_success "Environment variables configured"

# Create systemd service file for the Flask app
log_info "Configuring systemd service..."
sudo tee /etc/systemd/system/flask-app.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=Flask Web Application
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=$EC2_USER
WorkingDirectory=$APP_DEPLOYMENT_PATH
Environment="PATH=$APP_DEPLOYMENT_PATH/venv/bin"
ExecStart=$APP_DEPLOYMENT_PATH/venv/bin/python app.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/flask-app/app.log
StandardError=append:/var/log/flask-app/error.log

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Create log directory
log_info "Creating log directory..."
sudo mkdir -p /var/log/flask-app
sudo chown \$USER:\$USER /var/log/flask-app

# Reload systemd daemon and restart service
log_info "Restarting Flask application..."
sudo systemctl daemon-reload
sudo systemctl enable flask-app.service
sudo systemctl restart flask-app.service

log_success "Flask application restarted"

# Wait for service to be ready
log_info "Waiting for application to start..."
sleep 5

# Check if service is running
if systemctl is-active --quiet flask-app.service; then
    log_success "Flask application is running"
else
    log_error "Flask application failed to start"
    journalctl -u flask-app.service -n 20
    exit 1
fi

# Display deployment summary
log_info "========================================="
log_success "DEPLOYMENT COMPLETED SUCCESSFULLY"
log_info "========================================="
log_info "Environment: \$ENVIRONMENT"
log_info "Application Path: $APP_DEPLOYMENT_PATH"
log_info "Deployment ID: \$DEPLOYMENT_ID"
log_info "Deployed by: \$GITHUB_ACTOR"
log_info "Commit: \$GITHUB_SHA"
log_info "========================================="
log_info "Application logs: journalctl -u flask-app.service -f"
log_info "Application status: systemctl status flask-app.service"
log_info "View recent logs: tail -f /var/log/flask-app/app.log"
log_info "========================================="
"@

# Save script to temporary file
$scriptPath = "$env:TEMP\remote_deploy_$DEPLOYMENT_ID.sh"
$remoteScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force
Log-Info "Remote script prepared: $scriptPath"

# ============================================================================
# STEP 4: Upload script to EC2 via SSH
# ============================================================================
Log-Info "Uploading deployment script to EC2..."
try {
    scp -i $sshKeyPath `
        -P $SSH_PORT `
        -o "StrictHostKeyChecking=no" `
        -o "UserKnownHostsFile=/dev/null" `
        "$scriptPath" `
        "${EC2_USER}@${EC2_HOST}:/tmp/deploy_${DEPLOYMENT_ID}.sh" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Log-Success "Deployment script uploaded"
    } else {
        Log-Error "Failed to upload deployment script"
        exit 1
    }
} catch {
    Log-Error "SCP error: $_"
    exit 1
}

# ============================================================================
# STEP 5: Execute deployment script on EC2
# ============================================================================
Log-Info "Executing deployment on EC2..."
Log-Info "Connecting to: ${EC2_USER}@${EC2_HOST}:${SSH_PORT}"

try {
    ssh -i $sshKeyPath `
        -p $SSH_PORT `
        -o "StrictHostKeyChecking=no" `
        -o "UserKnownHostsFile=/dev/null" `
        -o "ConnectTimeout=30" `
        "${EC2_USER}@${EC2_HOST}" `
        "bash /tmp/deploy_${DEPLOYMENT_ID}.sh" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Log-Success "Remote deployment executed successfully"
    } else {
        Log-Error "Remote deployment failed with exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Log-Error "SSH execution error: $_"
    exit 1
}

# ============================================================================
# STEP 6: Cleanup
# ============================================================================
Log-Info "Cleaning up temporary files..."
Remove-Item -Path $scriptPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $sshKeyPath -Force -ErrorAction SilentlyContinue

Log-Success "========================================="
Log-Success "DEPLOYMENT COMPLETE"
Log-Success "========================================="
Log-Success "Environment: $ENVIRONMENT"
Log-Success "Deployment ID: $DEPLOYMENT_ID"
Log-Success "Application is now running on: http://${EC2_HOST}"
Log-Success "========================================="
