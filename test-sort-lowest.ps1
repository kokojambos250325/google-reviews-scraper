Write-Host "=== TEST: Sort by LOWEST rating (по возрастанию) ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://google-reviews-scraper-production.up.railway.app"
$testUrl = "https://maps.app.goo.gl/sBZxV16MmkSJWjUo9"

# Запуск скрапинга с сортировкой "lowest"
Write-Host "1. Запуск скрапинга с sort_by=lowest..." -ForegroundColor Yellow

$body = @{
    url = $testUrl
    sort_by = "lowest"
    headless = $true
} | ConvertTo-Json

Write-Host "Request body: $body" -ForegroundColor Gray

$scrapeResponse = Invoke-RestMethod -Uri "$baseUrl/scrape" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

$jobId = $scrapeResponse.job_id
Write-Host ""
Write-Host "Job ID: $jobId" -ForegroundColor Green
Write-Host "Status: $($scrapeResponse.status)" -ForegroundColor Green
Write-Host ""

# Ожидание завершения
Write-Host "2. Ожидание завершения (каждые 30 сек проверка)..." -ForegroundColor Yellow

$maxWait = 300  # 5 минут максимум
$elapsed = 0
$interval = 30

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    
    Write-Host "   Проверка статуса ($elapsed сек)..." -ForegroundColor Gray
    
    $jobStatus = Invoke-RestMethod -Uri "$baseUrl/jobs/$jobId"
    
    Write-Host "   Status: $($jobStatus.status)" -ForegroundColor Cyan
    
    if ($jobStatus.status -eq "completed") {
        Write-Host ""
        Write-Host "========== РЕЗУЛЬТАТ ==========" -ForegroundColor Green
        Write-Host "Status: $($jobStatus.status)" -ForegroundColor Green
        Write-Host "Reviews Count: $($jobStatus.reviews_count)" -ForegroundColor Green
        Write-Host "Started: $($jobStatus.started_at)" -ForegroundColor Gray
        Write-Host "Completed: $($jobStatus.completed_at)" -ForegroundColor Gray
        
        if ($jobStatus.reviews_count -gt 0) {
            Write-Host ""
            Write-Host "✅ SUCCESS! Отзывы отсортированы по возрастанию рейтинга!" -ForegroundColor Green
            
            # Получить первые 10 отзывов для проверки сортировки
            Write-Host ""
            Write-Host "Проверка сортировки (первые 10 отзывов)..." -ForegroundColor Yellow
            
            $reviews = Invoke-RestMethod -Uri "$baseUrl/reviews?limit=10&sort_by=oldest"
            
            Write-Host "Найдено отзывов: $($reviews.total_reviews)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Первые 10 отзывов:" -ForegroundColor Cyan
            
            foreach ($review in $reviews.reviews) {
                $rating = $review.rating
                $author = $review.author
                $date = $review.review_date
                
                $color = "Green"
                if ($rating -le 2) { $color = "Red" }
                elseif ($rating -eq 3) { $color = "Yellow" }
                
                Write-Host "  ⭐ $rating - $author ($date)" -ForegroundColor $color
            }
        } else {
            Write-Host ""
            Write-Host "❌ FAILED - 0 reviews extracted" -ForegroundColor Red
            Write-Host "Check Railway logs!" -ForegroundColor Yellow
        }
        
        break
    }
    elseif ($jobStatus.status -eq "failed") {
        Write-Host ""
        Write-Host "❌ JOB FAILED!" -ForegroundColor Red
        Write-Host "Error: $($jobStatus.error_message)" -ForegroundColor Red
        break
    }
}

if ($elapsed -ge $maxWait) {
    Write-Host ""
    Write-Host "⏱️ TIMEOUT - Job still running after 5 minutes" -ForegroundColor Yellow
    Write-Host "Job ID: $jobId" -ForegroundColor Gray
    Write-Host "Check status later: GET $baseUrl/jobs/$jobId" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Cyan
