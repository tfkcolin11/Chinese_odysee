# Chinese Odyssey Backend

This is the backend API for the Chinese Odyssey language learning application.

## Technology Stack

- **Framework**: NestJS with TypeScript
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT-based auth with refresh tokens
- **Caching**: Redis
- **Containerization**: Docker and Docker Compose

## Getting Started

### Prerequisites

- Node.js (v16+)
- Docker and Docker Compose
- PostgreSQL (if running locally without Docker)

### Installation

1. Clone the repository
2. Navigate to the backend directory:
   ```bash
   cd backend
   ```
3. Install dependencies:
   ```bash
   npm install
   ```

### Running with Docker

The easiest way to run the backend is using Docker Compose:

```bash
docker-compose up
```

This will start the following services:
- PostgreSQL database
- Redis cache
- NestJS API server

### Running Locally

1. Make sure PostgreSQL is running and accessible
2. Create a `.env` file based on the `.env.example` file
3. Run the development server:
   ```bash
   npm run start:dev
   ```

## API Documentation

Once the server is running, you can access the Swagger API documentation at:

```
http://localhost:3000/api/docs
```

## Project Structure

```
src/
├── auth/                 # Authentication module
├── user/                 # User management module
├── content/              # Content management module
├── conversation/         # Conversation module
├── subscription/         # Subscription management module
├── analytics/            # Analytics module
├── common/               # Shared utilities and helpers
├── app.module.ts         # Main application module
└── main.ts               # Application entry point
```

## Development

### Database Migrations

To generate a new migration:

```bash
npm run migration:generate -- -n MigrationName
```

To run migrations:

```bash
npm run migration:run
```

### Testing

Run unit tests:

```bash
npm run test
```

Run end-to-end tests:

```bash
npm run test:e2e
```

## Deployment

For production deployment, use the production Dockerfile:

```bash
docker build -t chinese-odyssey-api -f Dockerfile.prod .
```
