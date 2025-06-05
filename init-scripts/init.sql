-- Create a new user
CREATE USER postgres WITH PASSWORD 'postgres';

-- Create a new database
CREATE DATABASE fastapi_db;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE fastapi_db TO postgres;
