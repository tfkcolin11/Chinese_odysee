#!/bin/bash

# Change to the backend directory
cd backend

# Check if PostgreSQL is running
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
  echo "PostgreSQL is not running. Starting with Docker..."
  docker run --name chinese-odyssey-postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=chinese_odyssey -p 5432:5432 -d postgres:14
  
  # Wait for PostgreSQL to start
  echo "Waiting for PostgreSQL to start..."
  sleep 5
fi

# Run the backend in development mode
echo "Starting Chinese Odyssey backend in development mode..."
npm run start:dev
