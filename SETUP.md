# Content Platform Setup Guide

## Prerequisites
- Java 17+
- Node.js 16+
- PostgreSQL 13+
- MongoDB 5+
- Redis 6+

## Backend Setup

1. **Database Setup**
```sql
-- PostgreSQL
CREATE DATABASE contentplatform;
CREATE USER contentuser WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE contentplatform TO contentuser;
```

2. **Environment Variables**
```bash
export OPENAI_API_KEY=your-openai-api-key
export JWT_SECRET=your-jwt-secret-key
```

3. **Run Backend**
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

## Frontend Setup

1. **Install Dependencies**
```bash
cd frontend
npm install
```

2. **Start Development Server**
```bash
npm start
```

## Features Implemented

### 1. AI Blog Generator
- **Input Form**: Keywords, tone, word count, target audience
- **AI Generation**: OpenAI GPT integration for content creation
- **SEO Optimization**: Automatic title, meta description, tags generation
- **Rich Editor**: ReactQuill for content editing
- **Analytics**: SEO score calculation, reading time estimation

### 2. User Authentication
- **JWT-based**: Secure token authentication
- **Role-based Access**: Admin, Marketer, Reader roles
- **Protected Routes**: Frontend route protection

### 3. Database Integration
- **PostgreSQL**: User data, blog articles
- **MongoDB**: Ready for news articles and email templates
- **Redis**: Caching and session management

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

### Blog Management
- `POST /api/blogs/generate` - Generate blog with AI
- `POST /api/blogs/save` - Save blog draft
- `GET /api/blogs/my-blogs` - Get user's blogs
- `PUT /api/blogs/{id}/publish` - Publish blog

## Next Steps

1. **Complete News Feed Module**
   - ML recommendation engine
   - User behavior tracking
   - Article filtering and bookmarking

2. **Complete Email Builder Module**
   - Drag-and-drop interface
   - Template management
   - Campaign analytics

3. **Add Analytics Dashboard**
   - User engagement metrics
   - Content performance tracking
   - Campaign statistics

## Technology Stack

- **Backend**: Spring Boot 3.2, Spring Security, JPA
- **Frontend**: React 18, TypeScript, Material-UI
- **Database**: PostgreSQL, MongoDB, Redis
- **AI**: OpenAI GPT API
- **Authentication**: JWT tokens