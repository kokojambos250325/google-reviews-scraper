$jobId = "a730888f-c7e0-4060-9201-29584a00eda9"
$response = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/jobs/$jobId" -Method GET

Write-Host "Status: $($response.StatusCode)"
$result = $response.Content | ConvertFrom-Json
Write-Host "`nJob Status: $($result.status)"
Write-Host "Reviews Count: $($result.reviews_count)"
Write-Host "Error: $($result.error_message)"
Write-Host "`nFull response:"
$result | ConvertTo-Json -Depth 3
