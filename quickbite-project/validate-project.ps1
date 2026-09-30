$ErrorActionPreference = "Stop"
$services = "user-service", "restaurant-service", "order-service", "notification-service"
foreach ($service in $services) {
    foreach ($required in "Dockerfile", "build.gradle", "settings.gradle", "gradlew", "gradlew.bat", "src") {
        if (-not (Test-Path (Join-Path $service $required))) {
            throw "Missing $service/$required"
        }
    }
}

& docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw "docker-compose.yml is invalid" }
Write-Host "Project structure and docker-compose.yml are valid." -ForegroundColor Green
