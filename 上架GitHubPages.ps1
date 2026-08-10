# Wave Vapor 商品目錄 → GitHub Pages 上架腳本
# 雙擊或在 Git Bash / PowerShell 執行前，請先完成 gh 登入

$ErrorActionPreference = "Stop"
$env:Path = "$env:USERPROFILE\bin;$env:Path"
$repo = Join-Path $env:USERPROFILE "wavevapor-catalog"

Write-Host "=== 1) 檢查 gh 登入 ===" -ForegroundColor Cyan
gh auth status
if ($LASTEXITCODE -ne 0) {
  Write-Host "尚未登入。接下來會開啟瀏覽器，請在 GitHub 授權。" -ForegroundColor Yellow
  gh auth login --hostname github.com --git-protocol https --web
}

Write-Host "=== 2) 建立/更新 repo 並開啟 Pages ===" -ForegroundColor Cyan
Set-Location $repo

# create private or public? Pages free for public; private needs paid on old plans - use public for catalog
gh repo create wavevapor-catalog --public --source=. --remote=origin --push
if ($LASTEXITCODE -ne 0) {
  Write-Host "repo 可能已存在，改為 push..." -ForegroundColor Yellow
  git remote remove origin 2>$null
  $user = gh api user -q .login
  git remote add origin "https://github.com/$user/wavevapor-catalog.git"
  git push -u origin main
}

gh api -X POST "repos/{owner}/wavevapor-catalog/pages" -f build_type=legacy -f source[branch]=main -f source[path]=/ 2>$null
gh api -X PUT "repos/{owner}/wavevapor-catalog/pages" -f build_type=legacy -f source[branch]=main -f source[path]=/ 2>$null

$user = gh api user -q .login
$url = "https://$user.github.io/wavevapor-catalog/"
Write-Host ""
Write-Host "完成！約 1～2 分鐘後開啟：" -ForegroundColor Green
Write-Host $url -ForegroundColor Green
Write-Host "把此網址貼給 LINE 客人即可。"
Write-Host "若 404，到 GitHub repo → Settings → Pages 確認 Source = main / root"
pause
