Write-Host "Waiting for Railway deployment (120 sec)..."
Start-Sleep -Seconds 120

Write-Host "`n=== Testing with scroll fix ==="
$body = @{
    url = "https://maps.app.goo.gl/sBZxV16MmkSJWjUo9"
    max_reviews = 15
    sort_by = "newest"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/scrape" -Method POST -Body $body -ContentType "application/json"
$startResponse = $response.Content | ConvertFrom-Json
$jobId = $startResponse.job_id

Write-Host "Job ID: $jobId"
Start-Sleep -Seconds 60

$jobResponse = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/jobs/$jobId" -Method GET
$job = $jobResponse.Content | ConvertFrom-Json

Write-Host "`n=== FINAL RESULT ==="
Write-Host "Status: $($job.status)"
Write-Host "Reviews Count: $($job.reviews_count)"
if ($job.reviews_count -gt 0) {
    Write-Host "`n*** SUCCESS! REVIEWS EXTRACTED! ***" -ForegroundColor Green
} else {
    Write-Host "`n*** Still 0 reviews - check Railway logs ***" -ForegroundColor Yellow
}
