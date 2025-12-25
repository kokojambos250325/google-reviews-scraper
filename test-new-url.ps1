Write-Host "=== TEST: New URL with image downloads enabled ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://google-reviews-scraper-production.up.railway.app"
$testUrl = "https://maps.app.goo.gl/F445XdjwRwaHmiTs7"

Write-Host "Waiting 60 sec for Railway redeploy..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

Write-Host "Starting scrape job..." -ForegroundColor Yellow

$scrapeResponse = Invoke-RestMethod -Uri "$baseUrl/scrape" `
    -Method POST `
    -ContentType "application/json" `
    -Body (@{
        url = $testUrl
        sort_by = "newest"
    } | ConvertTo-Json)

$jobId = $scrapeResponse.job_id
Write-Host "Job ID: $jobId" -ForegroundColor Green
Write-Host ""

# Check every 30 seconds
$maxWait = 300
$elapsed = 0

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds 30
    $elapsed += 30
    
    $job = Invoke-RestMethod -Uri "$baseUrl/jobs/$jobId"
    Write-Host "[$elapsed sec] Status: $($job.status)" -ForegroundColor Cyan
    
    if ($job.status -eq "completed") {
        Write-Host ""
        Write-Host "========== SUCCESS ==========" -ForegroundColor Green
        Write-Host "Reviews: $($job.reviews_count)" -ForegroundColor Green
        Write-Host "Images: $($job.images_count)" -ForegroundColor Green
        break
    }
    elseif ($job.status -eq "failed") {
        Write-Host ""
        Write-Host "========== FAILED ==========" -ForegroundColor Red
        Write-Host "Error: $($job.error_message)" -ForegroundColor Red
        break
    }
}
