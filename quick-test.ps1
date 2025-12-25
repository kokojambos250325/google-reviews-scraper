Write-Host "Waiting for Railway deployment (120 sec)..."
Start-Sleep -Seconds 120

Write-Host "`n=== Starting scrape job ==="
$body = @{
    url = "https://www.google.com/maps/place/Azimut+Hotel+Munich/@48.1387848,11.5566188,17z"
    max_reviews = 5
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/scrape" -Method POST -Body $body -ContentType "application/json"
$startResponse = $response.Content | ConvertFrom-Json
$jobId = $startResponse.job_id

Write-Host "Job ID: $jobId"
Write-Host "`nWaiting 60 sec for completion..."
Start-Sleep -Seconds 60

$jobResponse = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/jobs/$jobId" -Method GET
$job = $jobResponse.Content | ConvertFrom-Json

Write-Host "`nStatus: $($job.status)"
Write-Host "Reviews: $($job.reviews_count)"
Write-Host "`n*** CHECK RAILWAY LOGS FOR div[jslog] STRUCTURE! ***"
