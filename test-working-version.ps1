Write-Host "Testing WORKING version (commit 3d998a1)" -ForegroundColor Green
Start-Sleep -Seconds 90
$r = Invoke-RestMethod -Uri "https://google-reviews-scraper-production.up.railway.app/scrape" -Method POST -ContentType "application/json" -Body '{"url":"https://maps.app.goo.gl/sBZxV16MmkSJWjUo9","sort_by":"newest"}'
Write-Host "Job: $($r.job_id)"
Start-Sleep -Seconds 120
$j = Invoke-RestMethod -Uri "https://google-reviews-scraper-production.up.railway.app/jobs/$($r.job_id)"
Write-Host "Status: $($j.status), Reviews: $($j.reviews_count)"
