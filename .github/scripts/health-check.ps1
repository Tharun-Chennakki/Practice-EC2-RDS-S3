param(
    [string]$EC2_HOST,
    [int]$APP_PORT = 5000,
    [int]$TIMEOUT_SECONDS = 10,
    [int]$MAX_RETRIES = 3
)

# Color codes
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
    Write-Host "$GREEN[✓]$RESET $Message"
}

function Log-Error {
    param([string]$Message)
    Write-Host "$RED[✗]$RESET $Message"
}

function Log-Warning {
    param([string]$Message)
    Write-Host "$YELLOW[⚠]$RESET $Message"
}

# Validate parameters
if (-not $EC2_HOST) {
    Log-Error "EC2_HOST parameter is required"
    exit 1
}

Log-Info "========================================="
Log-Info "Flask Application Health Check"
Log-Info "========================================="
Log-Info "Target: http://$EC2_HOST:$APP_PORT"
Log-Info "Timeout: $TIMEOUT_SECONDS seconds per attempt"
Log-Info "Max Retries: $MAX_RETRIES"
Log-Info "========================================="

$healthCheckUrl = "http://${EC2_HOST}:${APP_PORT}"
$retryCount = 0
$healthy = $false

while ($retryCount -lt $MAX_RETRIES) {
    try {
        Log-Info "Health check attempt $($retryCount + 1)/$MAX_RETRIES..."
        
        $response = Invoke-WebRequest -Uri $healthCheckUrl `
            -TimeoutSec $TIMEOUT_SECONDS `
            -ErrorAction Stop
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
            Log-Success "Application is responding (HTTP $($response.StatusCode))"
            $healthy = $true
            break
        }
    } catch [System.Net.WebException] {
        $exception = $_.Exception
        if ($exception.Response) {
            $statusCode = [int]$exception.Response.StatusCode
            Log-Warning "Received HTTP $statusCode"
            
            # 5xx errors indicate server issues
            if ($statusCode -ge 500) {
                Log-Warning "Server error received, waiting before retry..."
            } else {
                # 4xx errors might indicate the app is running but not healthy
                Log-Warning "Client error received"
            }
        } else {
            Log-Warning "Connection attempt failed: $($exception.Message)"
        }
        
        $retryCount++
        if ($retryCount -lt $MAX_RETRIES) {
            $waitSeconds = 5
            Log-Info "Waiting $waitSeconds seconds before retry..."
            Start-Sleep -Seconds $waitSeconds
        }
    } catch {
        Log-Warning "Unexpected error: $($_.Exception.Message)"
        $retryCount++
        if ($retryCount -lt $MAX_RETRIES) {
            Start-Sleep -Seconds 5
        }
    }
}

Log-Info "========================================="

if ($healthy) {
    Log-Success "HEALTH CHECK PASSED"
    Log-Info "Application is ready to handle requests"
    Log-Info "URL: $healthCheckUrl"
    exit 0
} else {
    Log-Error "HEALTH CHECK FAILED"
    Log-Error "Application is not responding after $MAX_RETRIES attempts"
    Log-Error "URL: $healthCheckUrl"
    Log-Info ""
    Log-Info "Troubleshooting steps:"
    Log-Info "1. Check if application is running:"
    Log-Info "   ssh -i your-key.pem ubuntu@$EC2_HOST"
    Log-Info "   sudo systemctl status flask-app.service"
    Log-Info ""
    Log-Info "2. View application logs:"
    Log-Info "   sudo journalctl -u flask-app.service -n 50"
    Log-Info ""
    Log-Info "3. Check if port $APP_PORT is listening:"
    Log-Info "   sudo netstat -tlnp | grep :$APP_PORT"
    Log-Info ""
    Log-Info "4. Verify security group allows port $APP_PORT"
    exit 1
}
