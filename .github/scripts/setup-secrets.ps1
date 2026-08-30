# PowerShell script to help set up GitHub Secrets for CI/CD
# Run this locally to configure your repository secrets

# This script provides instructions for configuring GitHub Secrets via GitHub CLI or WebUI

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "GitHub Secrets Setup for CI/CD Pipeline" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "REQUIRED SECRETS TO CONFIGURE:" -ForegroundColor Yellow
Write-Host ""

$secrets = @(
    @{Name = "AWS_ACCESS_KEY_ID"; Description = "AWS IAM Access Key ID"; Required = $true},
    @{Name = "AWS_SECRET_ACCESS_KEY"; Description = "AWS IAM Secret Access Key"; Required = $true},
    @{Name = "AWS_REGION"; Description = "AWS Region (e.g., us-east-1)"; Required = $true},
    @{Name = "EC2_HOST"; Description = "EC2 Instance Public IP or DNS"; Required = $true},
    @{Name = "EC2_USER"; Description = "EC2 SSH User (usually 'ubuntu' or 'ec2-user')"; Required = $true},
    @{Name = "SSH_PORT"; Description = "SSH Port (default: 22)"; Required = $false},
    @{Name = "SSH_PRIVATE_KEY"; Description = "EC2 SSH Private Key (PEM format, base64 encoded)"; Required = $true},
    @{Name = "APP_DEPLOYMENT_PATH"; Description = "Application deployment path on EC2"; Required = $false},
    @{Name = "DB_HOST"; Description = "AWS RDS MySQL Host"; Required = $true},
    @{Name = "DB_USER"; Description = "RDS Database Username"; Required = $true},
    @{Name = "DB_PASSWORD"; Description = "RDS Database Password"; Required = $true},
    @{Name = "DB_NAME"; Description = "Database Name"; Required = $true},
    @{Name = "DB_PORT"; Description = "RDS Database Port (default: 3306)"; Required = $false},
    @{Name = "APP_SECRET_KEY"; Description = "Flask Application Secret Key"; Required = $true},
    @{Name = "SLACK_WEBHOOK_URL"; Description = "Slack Webhook URL (optional, for notifications)"; Required = $false}
)

$counter = 1
foreach ($secret in $secrets) {
    $required = if ($secret.Required) { "[REQUIRED]" } else { "[OPTIONAL]" }
    Write-Host "$counter. $($secret.Name) $required" -ForegroundColor Green
    Write-Host "   Description: $($secret.Description)" -ForegroundColor Gray
    Write-Host ""
    $counter++
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "HOW TO ADD SECRETS - Choose One Method:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "METHOD 1: Using GitHub CLI (Recommended)" -ForegroundColor Yellow
Write-Host "Prerequisites: Install GitHub CLI - https://cli.github.com/" -ForegroundColor Gray
Write-Host ""
Write-Host "Commands:" -ForegroundColor Gray
Write-Host "  gh auth login"
Write-Host "  gh secret set AWS_ACCESS_KEY_ID --body 'YOUR_VALUE' -R owner/repo-name"
Write-Host "  gh secret set AWS_SECRET_ACCESS_KEY --body 'YOUR_VALUE' -R owner/repo-name"
Write-Host "  gh secret set AWS_REGION --body 'us-east-1' -R owner/repo-name"
Write-Host "  # ... repeat for other secrets"
Write-Host ""

Write-Host "METHOD 2: Using GitHub Web UI" -ForegroundColor Yellow
Write-Host "Steps:" -ForegroundColor Gray
Write-Host "  1. Go to your repository on GitHub"
Write-Host "  2. Click Settings"
Write-Host "  3. In the left sidebar, click 'Secrets and variables' > 'Actions'"
Write-Host "  4. Click 'New repository secret'"
Write-Host "  5. Enter the secret name and value"
Write-Host "  6. Click 'Add secret'"
Write-Host "  7. Repeat for each secret"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SPECIAL SETUP INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "For SSH_PRIVATE_KEY Secret:" -ForegroundColor Yellow
Write-Host "  1. Locate your .pem file (EC2 key pair)"
Write-Host "  2. Open it with Notepad"
Write-Host "  3. Copy the entire content including BEGIN and END lines"
Write-Host "  4. Paste as the secret value"
Write-Host "  NOTE: Make sure the entire key is copied, including newlines"
Write-Host ""

Write-Host "For Flask APP_SECRET_KEY:" -ForegroundColor Yellow
Write-Host "  Generate a secure key using Python:"
Write-Host "  python -c 'import secrets; print(secrets.token_hex(32))'"
Write-Host ""

Write-Host "For SLACK_WEBHOOK_URL (Optional):" -ForegroundColor Yellow
Write-Host "  1. Create a Slack App: https://api.slack.com/apps"
Write-Host "  2. Enable Incoming Webhooks"
Write-Host "  3. Create a new webhook URL"
Write-Host "  4. Copy the URL as the secret value"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "EXAMPLE GITHUB CLI SCRIPT:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$exampleScript = @"
# Run these commands to set up all secrets
# Replace with your actual values!

gh secret set AWS_ACCESS_KEY_ID --body 'YOUR_AWS_ACCESS_KEY'
gh secret set AWS_SECRET_ACCESS_KEY --body 'YOUR_AWS_SECRET_KEY'
gh secret set AWS_REGION --body 'us-east-1'
gh secret set EC2_HOST --body 'your-ec2-public-ip-or-dns'
gh secret set EC2_USER --body 'ubuntu'
gh secret set SSH_PORT --body '22'
gh secret set SSH_PRIVATE_KEY --body '$(Get-Content -Path 'path/to/your/key.pem' -Raw)'
gh secret set APP_DEPLOYMENT_PATH --body '/home/ubuntu/flask-app'
gh secret set DB_HOST --body 'your-rds-endpoint.us-east-1.rds.amazonaws.com'
gh secret set DB_USER --body 'admin'
gh secret set DB_PASSWORD --body 'your-secure-password'
gh secret set DB_NAME --body 'flask_db'
gh secret set DB_PORT --body '3306'
gh secret set APP_SECRET_KEY --body 'your-generated-secret-key'
gh secret set SLACK_WEBHOOK_URL --body 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL' (Optional)
"@

Write-Host $exampleScript -ForegroundColor Gray
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "VERIFY SECRETS:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "List all secrets:" -ForegroundColor Gray
Write-Host "  gh secret list -R owner/repo-name"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Configure all required secrets above"
Write-Host "2. Push your code to the main branch:"
Write-Host "   git push origin main"
Write-Host "3. CI workflow will run automatically"
Write-Host "4. Go to GitHub Actions tab to trigger manual deployment"
Write-Host "5. Click 'Deploy to AWS EC2' workflow"
Write-Host "6. Click 'Run workflow' and select options"
Write-Host "7. Monitor the deployment in the Actions tab"
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
