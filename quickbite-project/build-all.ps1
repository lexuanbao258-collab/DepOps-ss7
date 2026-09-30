$ErrorActionPreference = "Stop"

$javaVersion = (& java -version 2>&1 | Select-Object -First 1) -join ""
if ($javaVersion -notmatch '"17[\.]') {
    throw "Bai tap yeu cau JDK 17. Java hien tai: $javaVersion"
}

& docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Docker daemon chua chay. Hay mo Docker Desktop roi thu lai."
}

$services = @(
    @{ Path = "user-service";         Image = "quickbite-user-service:latest" },
    @{ Path = "restaurant-service";   Image = "quickbite-restaurant-service:latest" },
    @{ Path = "order-service";        Image = "quickbite-order-service:latest" },
    @{ Path = "notification-service"; Image = "quickbite-notification-service:latest" }
)

foreach ($service in $services) {
    Write-Host "`n=== Building $($service.Path) ===" -ForegroundColor Cyan
    Push-Location $service.Path
    try {
        & .\gradlew.bat clean bootJar --no-daemon
        if ($LASTEXITCODE -ne 0) { throw "Gradle build failed: $($service.Path)" }

        $jars = @(Get-ChildItem .\build\libs\*.jar -File)
        if ($jars.Count -ne 1) {
            throw "Expected exactly 1 JAR in $($service.Path)\build\libs, found $($jars.Count)."
        }

        & docker build -t $service.Image .
        if ($LASTEXITCODE -ne 0) { throw "Docker build failed: $($service.Image)" }
    }
    finally {
        Pop-Location
    }
}

Write-Host "`n=== QuickBite images ===" -ForegroundColor Green
& docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" | Select-String "quickbite-"
