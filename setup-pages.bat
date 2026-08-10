@echo off
setlocal EnableExtensions
chcp 65001 >nul
set "PATH=%USERPROFILE%\bin;%PATH%"
set "REPO=%USERPROFILE%\wavevapor-catalog"

echo.
echo ========================================
echo  WaveVapor catalog - GitHub Pages setup
echo ========================================
echo.

where gh >nul 2>&1
if errorlevel 1 (
  if exist "%USERPROFILE%\bin\gh.exe" set "PATH=%USERPROFILE%\bin;%PATH%"
)
where gh >nul 2>&1
if errorlevel 1 (
  echo ERROR: gh.exe not found. Put gh.exe in %USERPROFILE%\bin\
  pause
  exit /b 1
)

echo [1/4] GitHub login - browser will open. Approve access, then return here.
echo.
gh auth status >nul 2>&1
if errorlevel 1 (
  gh auth login --hostname github.com --git-protocol https --web
  if errorlevel 1 (
    echo ERROR: login failed
    pause
    exit /b 1
  )
) else (
  echo Already logged in.
  gh auth status
)

echo.
echo [2/4] Reading GitHub username...
for /f "usebackq delims=" %%u in (`gh api user -q .login`) do set "GHUSER=%%u"
if not defined GHUSER (
  echo ERROR: cannot read GitHub username
  pause
  exit /b 1
)
echo Username: %GHUSER%

echo.
echo [3/4] Push repo wavevapor-catalog
cd /d "%REPO%"
if errorlevel 1 (
  echo ERROR: folder not found: %REPO%
  pause
  exit /b 1
)

gh repo view "%GHUSER%/wavevapor-catalog" >nul 2>&1
if errorlevel 1 (
  echo Creating new public repo...
  gh repo create wavevapor-catalog --public --source=. --remote=origin --push
  if errorlevel 1 (
    echo ERROR: repo create or push failed
    pause
    exit /b 1
  )
) else (
  echo Repo exists. Pushing main...
  git remote remove origin 2>nul
  git remote add origin "https://github.com/%GHUSER%/wavevapor-catalog.git"
  git push -u origin main
  if errorlevel 1 (
    echo ERROR: git push failed
    pause
    exit /b 1
  )
)

echo.
echo [4/4] Enable GitHub Pages...
gh api --method POST "repos/%GHUSER%/wavevapor-catalog/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
gh api --method PUT "repos/%GHUSER%/wavevapor-catalog/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" >nul 2>&1

echo.
echo ========================================
echo  DONE. Open this URL in 1-2 minutes:
echo.
echo  https://%GHUSER%.github.io/wavevapor-catalog/
echo.
echo  If 404: GitHub repo - Settings - Pages
echo  Source = Deploy from branch, main, / root
echo ========================================
echo.
pause
endlocal
