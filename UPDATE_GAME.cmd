@echo off
setlocal enabledelayedexpansion

REM Configuration
set BRANCH_NAME=main
set SCRIPT_NAME=%~nx0

echo Step 1: Preparing the repository
REM Ensure we're in the correct directory
cd /d "%~dp0"

echo Step 2: Acquiring GitHub repository URL
for /f "tokens=*" %%a in ('git config --get remote.origin.url 2^>nul') do set REPO_URL=%%a
if "%REPO_URL%"=="" (
    echo Error: Could not acquire GitHub repository URL.
    echo Please ensure this is a Git repository and has a remote named 'origin'.
    echo Verify by running 'git remote -v' in the repository directory.
    pause
    exit /b 1
)
echo Repository URL: %REPO_URL%

echo Step 3: Backing up important files
REM Create a temporary directory for important files
if not exist temp_backup mkdir temp_backup
copy %SCRIPT_NAME% temp_backup\

echo Step 4: Resetting the repository
REM Ensure the .git directory is completely removed
if exist .git (
    attrib -r -h -s .git
    rmdir /s /q .git
)

echo Step 5: Initializing a new repository
REM Initialize a new git repository with the main branch
git init -b main

echo Step 6: Copying new build files
REM Ensure your new Unity WebGL build is in this directory

echo Step 7: Restoring backed-up files
REM Restore the backed-up files
xcopy /y temp_backup\* .
rmdir /s /q temp_backup

echo Step 8: Committing changes
git add -A
git commit -m "Reset repository with latest WebGL build %date%"

echo Step 9: Pushing to GitHub
git remote add origin %REPO_URL%
git push -f origin %BRANCH_NAME%

echo Process completed. Repository has been reset and updated.
pause
