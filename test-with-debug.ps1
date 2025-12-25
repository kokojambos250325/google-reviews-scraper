Write-Host "Waiting for Railway deployment..."
Start-Sleep -Seconds 120

Write-Host "`n=== Starting new scrape job ==="
$body = @{
    url = "https://www.google.com/maps/place/Azimut+Hotel+Munich/@48.1387848,11.5566188,17z"
    max_reviews = 10
    sort_by = "newest"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/scrape" -Method POST -Body $body -ContentType "application/json"
$startResponse = $response.Content | ConvertFrom-Json
$jobId = $startResponse.job_id

Write-Host "Job ID: $jobId"
Write-Host "Status: $($startResponse.status)"

Write-Host "`n=== Waiting 60 seconds for job to complete ==="
Start-Sleep -Seconds 60

Write-Host "`n=== Checking job status ==="
$jobResponse = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/jobs/$jobId" -Method GET
$job = $jobResponse.Content | ConvertFrom-Json

Write-Host "`nJob Status: $($job.status)"
Write-Host "Reviews Count: $($job.reviews_count)"
Write-Host "Error: $($job.error_message)"
Write-Host "`nCheck Railway logs for DEBUG output!"
