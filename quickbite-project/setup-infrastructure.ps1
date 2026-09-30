$ErrorActionPreference = "Stop"

& docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Docker daemon chua chay. Hay mo Docker Desktop roi thu lai."
}

& docker network inspect quickbite-net *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating external network quickbite-net..." -ForegroundColor Cyan
    & docker network create quickbite-net
    if ($LASTEXITCODE -ne 0) { throw "Khong tao duoc network quickbite-net." }
} else {
    Write-Host "Network quickbite-net already exists." -ForegroundColor Green
}

& docker compose -f infrastructure/docker-compose-db.yml up -d
if ($LASTEXITCODE -ne 0) { throw "Khong khoi dong duoc quickbite-db." }

Write-Host "Waiting for PostgreSQL..." -ForegroundColor Cyan
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    & docker exec quickbite-db pg_isready -U postgres *> $null
    if ($LASTEXITCODE -eq 0) {
        $ready = $true
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $ready) {
    throw "PostgreSQL khong healthy sau 60 giay. Chay: docker logs quickbite-db"
}

Write-Host "quickbite-db is ready on quickbite-net." -ForegroundColor Green
