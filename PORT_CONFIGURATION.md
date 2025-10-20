# Port Configuration Guide

## Current Port Setup

### Backend (Spring Boot)
- **Port**: 9090
- **Base URL**: http://localhost:9090
- **API Endpoints**: http://localhost:9090/api/*
- **Status Check**: http://localhost:9090/api/auth/status
- **H2 Database Console**: http://localhost:9090/h2-console

### Frontend (React)
- **Port**: 3000
- **Base URL**: http://localhost:3000
- **Proxy**: Configured to proxy API calls to backend on port 9090

## Quick Start

### Option 1: Using Batch Files (Recommended)
1. **Start Backend**: Double-click `start-backend.bat`
2. **Start Frontend**: Double-click `start-frontend.bat`
3. **Test Backend**: Visit http://localhost:9090/api/auth/status
4. **Access App**: Visit http://localhost:3000

### Option 2: Manual Start
1. **Backend**:
   ```bash
   cd backend
   mvn spring-boot:run
   ```

2. **Frontend**:
   ```bash
   cd frontend
   npm install
   npm start
   ```

## Testing Backend Status

Once the backend is running, you can test it by visiting:
```
http://localhost:9090/api/auth/status
```

Expected response:
```json
{
  "status": "UP",
  "message": "Content Platform Backend is running",
  "timestamp": "2024-01-XX...",
  "port": 9090
}
```

## Configuration Files Updated

1. **backend/src/main/resources/application.yml** - Backend port set to 9090
2. **frontend/package.json** - Frontend port set to 3000, proxy to 9090
3. **frontend/src/services/api.ts** - API base URL updated to port 9090
4. **launch-fullstack.bat** - Updated port references
5. **AuthController.java** - Added proper GET /api/auth/status endpoint

## Troubleshooting

- If port 9090 is in use, change it in `application.yml`
- If port 3000 is in use, React will automatically suggest port 3001
- Make sure both ports are not blocked by firewall
- Check that no other applications are using these ports