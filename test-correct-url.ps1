Write-Host "Testing with correct Google Maps shortlink..."

$body = @{
    url = "https://maps.app.goo.gl/sBZxV16MmkSJWjUo9"
    max_reviews = 10
    sort_by = "newest"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/scrape" -Method POST -Body $body -ContentType "application/json"
$startResponse = $response.Content | ConvertFrom-Json
$jobId = $startResponse.job_id

Write-Host "Job ID: $jobId"
Write-Host "Status: $($startResponse.status)"

Write-Host "`nWaiting 60 seconds for scraping..."
Start-Sleep -Seconds 60

$jobResponse = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/jobs/$jobId" -Method GET
$job = $jobResponse.Content | ConvertFrom-Json

Write-Host "`n=== RESULTS ==="
Write-Host "Status: $($job.status)"
Write-Host "Reviews Count: $($job.reviews_count)"
Write-Host "Error: $($job.error_message)"
Write-Host "`nCheck Railway logs!"
