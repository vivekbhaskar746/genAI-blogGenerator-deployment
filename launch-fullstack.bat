@echo off
echo ========================================
echo   AI Content Platform - Full Launch
echo ========================================
echo.

echo [1/4] Compiling Backend...
cd backend
javac -cp "src/main/java" -d target/classes src/main/java/com/contentplatform/*.java src/main/java/com/contentplatform/*/*.java 2>nul

echo [2/4] Starting Backend Server...
start "Backend Server" cmd /k "java -cp target/classes com.contentplatform.ContentPlatformApplication"

echo [3/4] Waiting for backend startup...
timeout /t 5 /nobreak >nul

echo [4/4] Opening Frontend Applications...
cd ..
start "Auth Blog Generator" auth-blog-generator.html
start "Direct Blog Generator" nebius-blog-generator.html

echo.
echo ========================================
echo   Full-Stack Application Launched!
echo ========================================
echo.
echo Backend API:     http://localhost:9090
echo H2 Database:     http://localhost:9090/h2-console
echo Auth Interface:  auth-blog-generator.html
echo Direct Access:   nebius-blog-generator.html
echo.
echo JDBC URL: jdbc:h2:mem:contentplatform
echo Username: sa
echo Password: (empty)
echo.
pause