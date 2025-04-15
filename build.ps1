
$baseImageName = "updateduckdns"
$imageMajorVersion = "1.0"
$pythonVersion = "3.13.3"
$alpineVersion = "alpine3.21"
$dockerHubUsername = "lordraw"

$detailedTag = "$imageMajorVersion-$pythonVersion-$alpineVersion"

Write-Host "===== Configurazione del build Docker =====" -ForegroundColor Cyan
Write-Host "Nome immagine base: $baseImageName" -ForegroundColor Yellow
Write-Host "Versione immagine: $imageMajorVersion" -ForegroundColor Yellow
Write-Host "Versione Python: $pythonVersion" -ForegroundColor Yellow
Write-Host "Versione Alpine: $alpineVersion" -ForegroundColor Yellow
Write-Host "Tag dettagliato: $detailedTag" -ForegroundColor Yellow
Write-Host "Username Docker Hub: $dockerHubUsername" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "Costruzione dell'immagine Docker..." -ForegroundColor Green
docker build -t "$baseImageName`:$imageMajorVersion" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Errore durante la costruzione dell'immagine Docker!" -ForegroundColor Red
    exit 1
}

Write-Host "Creazione dei tag locali..." -ForegroundColor Green
docker tag "$baseImageName`:$imageMajorVersion" "$baseImageName`:latest"
docker tag "$baseImageName`:$imageMajorVersion" "$baseImageName`:$detailedTag"

Write-Host "Creazione dei tag per Docker Hub..." -ForegroundColor Green
docker tag "$baseImageName`:$imageMajorVersion" "$dockerHubUsername/$baseImageName`:$imageMajorVersion"
docker tag "$baseImageName`:latest" "$dockerHubUsername/$baseImageName`:latest"
docker tag "$baseImageName`:$detailedTag" "$dockerHubUsername/$baseImageName`:$detailedTag"


Write-Host "Verificando login su Docker Hub..." -ForegroundColor Yellow
$loginTestResult = docker login --help 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker CLI non disponibile. Assicurati che Docker sia installato e in esecuzione." -ForegroundColor Red
    exit 1
}

Write-Host "Tentativo di verifica delle credenziali Docker Hub..." -ForegroundColor Yellow
$testAuth = docker pull hello-world 2>&1
if ($LASTEXITCODE -ne 0 -and $testAuth -like "*authentication required*") {
    Write-Host "Non sei loggato su Docker Hub. Esegui 'docker login' prima di procedere." -ForegroundColor Red
    docker login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Login fallito. Impossibile procedere." -ForegroundColor Red
        exit 1
    }
}


Write-Host "Avvio push delle immagini su Docker Hub..." -ForegroundColor Green
docker push "$dockerHubUsername/$baseImageName`:$imageMajorVersion"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Push del tag '$imageMajorVersion' completato con successo." -ForegroundColor Green
} else {
    Write-Host "Errore durante il push del tag '$imageMajorVersion'." -ForegroundColor Red
}

docker push "$dockerHubUsername/$baseImageName`:$detailedTag"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Push del tag '$detailedTag' completato con successo." -ForegroundColor Green
} else {
    Write-Host "Errore durante il push del tag '$detailedTag'." -ForegroundColor Red
}

docker push "$dockerHubUsername/$baseImageName`:latest"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Push del tag 'latest' completato con successo." -ForegroundColor Green
} else {
    Write-Host "Errore durante il push del tag 'latest'." -ForegroundColor Red
}

Write-Host "Processo completato!" -ForegroundColor Cyan