$body = @{
    url = "https://www.google.com/maps/place/Azimut+Hotel+Munich/@48.1387848,11.5566188,17z"
    max_reviews = 10
    sort_by = "newest"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "https://google-reviews-scraper-production.up.railway.app/scrape" -Method POST -Body $body -ContentType "application/json"

Write-Host "Status: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
