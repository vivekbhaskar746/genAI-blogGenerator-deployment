@echo off
echo ========================================
echo   Starting Content Platform Backend
echo ========================================
echo.
echo Backend will run on: http://localhost:9090
echo Status endpoint: http://localhost:9090/api/auth/status
echo H2 Console: http://localhost:9090/h2-console
echo.

cd backend

echo Checking for Maven...
where mvn >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using Maven to start backend...
    mvn spring-boot:run
) else (
    echo Maven not found, using manual compilation...
    if not exist "target\classes" mkdir target\classes
    
    javac -cp "src/main/java" -d target/classes src/main/java/com/contentplatform/*.java src/main/java/com/contentplatform/*/*.java
    
    if %ERRORLEVEL% NEQ 0 (
        echo Compilation failed!
        pause
        exit /b 1
    )
    
    echo Starting backend server...
    java -cp target/classes com.contentplatform.ContentPlatformApplication
)

pause