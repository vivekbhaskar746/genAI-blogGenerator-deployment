@echo off
echo ========================================
echo   Starting Content Platform Frontend
echo ========================================
echo.
echo Frontend will run on: http://localhost:3000
echo Make sure backend is running on: http://localhost:9090
echo.

cd frontend
echo Installing dependencies...
call npm install

echo Starting frontend server...
call npm start

pause