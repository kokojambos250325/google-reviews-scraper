Write-Host "=== DEMO: Google Reviews Scraper API ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://google-reviews-scraper-production.up.railway.app"
$testUrl = "https://maps.app.goo.gl/sBZxV16MmkSJWjUo9"

# 1. Запуск скрапинга с сортировкой "newest"
Write-Host "1. Запуск скрапинга (sort_by=newest)..." -ForegroundColor Yellow
$scrapeResponse = Invoke-RestMethod -Uri "$baseUrl/scrape" `
    -Method POST `
    -ContentType "application/json" `
    -Body (@{
        url = $testUrl
        sort_by = "newest"
        headless = $true
    } | ConvertTo-Json)

$jobId = $scrapeResponse.job_id
Write-Host "   Job ID: $jobId" -ForegroundColor Green
Write-Host "   Status: $($scrapeResponse.status)" -ForegroundColor Green
Write-Host ""

# 2. Проверка статуса
Write-Host "2. Ожидание завершения (60 сек)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

$jobStatus = Invoke-RestMethod -Uri "$baseUrl/jobs/$jobId"
Write-Host "   Status: $($jobStatus.status)" -ForegroundColor Green
Write-Host "   Reviews: $($jobStatus.reviews_count)" -ForegroundColor Green
Write-Host ""

# 3. Получение данных через /reviews endpoint
Write-Host "3. Получение данных через /reviews..." -ForegroundColor Yellow

# 3a. Все отзывы с сортировкой по новым
Write-Host "   a) Сортировка: newest, лимит 10" -ForegroundColor Cyan
$reviews1 = Invoke-RestMethod -Uri "$baseUrl/reviews?sort_by=newest&limit=10"
Write-Host "      Найдено: $($reviews1.total_reviews)" -ForegroundColor Green
Write-Host "      Возвращено: $($reviews1.returned_reviews)" -ForegroundColor Green

# 3b. Только 4-5 звёзд
Write-Host "   b) Фильтр: min_rating=4, sort_by=highest_rating" -ForegroundColor Cyan
$reviews2 = Invoke-RestMethod -Uri "$baseUrl/reviews?min_rating=4&sort_by=highest_rating&limit=10"
Write-Host "      Найдено: $($reviews2.total_reviews)" -ForegroundColor Green
Write-Host "      Возвращено: $($reviews2.returned_reviews)" -ForegroundColor Green

# 3c. Только 1-2 звезды
Write-Host "   c) Фильтр: max_rating=2, sort_by=lowest_rating" -ForegroundColor Cyan
$reviews3 = Invoke-RestMethod -Uri "$baseUrl/reviews?max_rating=2&sort_by=lowest_rating&limit=10"
Write-Host "      Найдено: $($reviews3.total_reviews)" -ForegroundColor Green
Write-Host "      Возвращено: $($reviews3.returned_reviews)" -ForegroundColor Green

# 3d. Пагинация
Write-Host "   d) Пагинация: offset=20, limit=10" -ForegroundColor Cyan
$reviews4 = Invoke-RestMethod -Uri "$baseUrl/reviews?offset=20&limit=10&sort_by=newest"
Write-Host "      Найдено: $($reviews4.total_reviews)" -ForegroundColor Green
Write-Host "      Возвращено: $($reviews4.returned_reviews)" -ForegroundColor Green
Write-Host "      Has more: $($reviews4.has_more)" -ForegroundColor Green

Write-Host ""
Write-Host "=== Примеры запросов для заказчика ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "# Запуск скрапинга:" -ForegroundColor Yellow
Write-Host "POST $baseUrl/scrape"
Write-Host '{
  "url": "https://maps.app.goo.gl/...",
  "sort_by": "newest"
}' -ForegroundColor Gray
Write-Host ""

Write-Host "# Получение только положительных отзывов:" -ForegroundColor Yellow
Write-Host "GET $baseUrl/reviews?min_rating=4&sort_by=highest_rating&limit=50"
Write-Host ""

Write-Host "# Получение только негативных отзывов:" -ForegroundColor Yellow
Write-Host "GET $baseUrl/reviews?max_rating=2&sort_by=newest&limit=20"
Write-Host ""

Write-Host "# Пагинация (страница 2):" -ForegroundColor Yellow
Write-Host "GET $baseUrl/reviews?offset=50&limit=50&sort_by=newest"
Write-Host ""

Write-Host "=== DEMO завершена ===" -ForegroundColor Cyan
