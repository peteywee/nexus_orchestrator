#!/bin/bash

# ==============================================================================
# Nexus Orchestrator - Master Project Scaffolding Script
# ==============================================================================
# This script creates the complete directory structure and all necessary
# configuration files for the simplified Node.js version of the project.
# Run it in an empty directory to build the project from scratch.
# ==============================================================================

set -e # Exit immediately if a command fails

# --- Colors for Output ---
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${BLUE}--- Starting Nexus Orchestrator Project Scaffolding ---${NC}"

# --- 1. Create Directory Structure ---
echo -e "\n${YELLOW}[1/6] Creating project directory structure...${NC}"
mkdir -p .github/workflows backend nexusmind-web-ui
echo -e "${GREEN}✓ Directories created.${NC}"

# --- 2. Create Root-Level Files ---
echo -e "\n${YELLOW}[2/6] Creating root-level files (Dockerfile, .dockerignore)...${NC}"

# Create root Dockerfile
cat << 'EOF' > Dockerfile
# Stage 1: Install dependencies
FROM node:20-alpine as deps

WORKDIR /app

# Copy the package.json and package-lock.json from the backend
COPY backend/package*.json ./

# Install production dependencies using 'npm ci' for reliability
RUN npm ci

# Stage 2: Create the final production image
FROM node:20-alpine

WORKDIR /app

# Copy the installed node_modules from the 'deps' stage
COPY --from=deps /app/node_modules ./node_modules

# Copy the backend application code
COPY backend .

# Copy the static frontend files into the 'public' directory,
# which the backend will serve.
COPY nexusmind-web-ui ./public

# Expose the port that the backend server will run on
EXPOSE 3000

# The command to start the Node.js backend server
CMD ["node", "index.js"]
EOF
echo "  - Dockerfile created."

# Create .dockerignore
cat << 'EOF' > .dockerignore
# Ignore Node.js dependency folders
node_modules
backend/node_modules

# Ignore Git and GitHub specific files
.git
.github

# Ignore local environment files
.env
EOF
echo "  - .dockerignore created."
echo -e "${GREEN}✓ Root files created.${NC}"

# --- 3. Create Backend Files ---
echo -e "\n${YELLOW}[3/6] Creating backend files (index.js, package.json)...${NC}"

# Create backend/package.json
cat << 'EOF' > backend/package.json
{
  "name": "nexus-backend",
  "version": "1.0.0",
  "description": "Backend server for Nexus Orchestrator",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.19.2"
  }
}
EOF
echo "  - backend/package.json created."

# Create backend/index.js
cat << 'EOF' > backend/index.js
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

// Since we are using ES modules, __dirname is not available directly.
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files (your index.html, css, js) from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// API health check route
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Nexus Backend is healthy' });
});

// Fallback route for Single-Page Applications (SPA)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/index.html'));
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
EOF
echo "  - backend/index.js created."
echo -e "${GREEN}✓ Backend files created.${NC}"

# --- 4. Create Frontend File ---
echo -e "\n${YELLOW}[4/6] Creating frontend file (index.html)...${NC}"

cat << 'EOF' > nexusmind-web-ui/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Orchestrator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-gray-900 text-gray-200 flex flex-col items-center justify-center min-h-screen p-4">

    <div class="w-full max-w-3xl bg-gray-800/50 backdrop-blur-sm border border-cyan-500/20 rounded-xl shadow-2xl shadow-cyan-500/10 p-8">
        <h1 class="text-4xl font-bold text-center text-cyan-400 mb-2">Nexus Orchestrator</h1>
        <p class="text-center text-gray-400 mb-8">A Single-Container Node.js Application</p>

        <!-- Status Check -->
        <div class="mb-6">
            <h2 class="text-xl font-semibold mb-2 text-gray-300">System Status</h2>
            <div id="status-container" class="bg-gray-900/50 p-4 rounded-lg flex items-center justify-between border border-gray-700">
                <span id="status-text" class="text-gray-400">Checking API status...</span>
                <div id="status-indicator" class="w-4 h-4 rounded-full bg-yellow-500 animate-pulse"></div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const statusText = document.getElementById('status-text');
            const statusIndicator = document.getElementById('status-indicator');

            const checkApiHealth = async () => {
                try {
                    // Use a relative path, as the API is served by the same server
                    const response = await fetch('/api/health');
                    if (response.ok) {
                        const data = await response.json();
                        if (data.status === 'ok') {
                            statusText.textContent = 'API is online and healthy.';
                            statusIndicator.className = 'w-4 h-4 rounded-full bg-green-500';
                        }
                    } else {
                       throw new Error(`HTTP error! status: ${response.status}`);
                    }
                } catch (error) {
                    console.error('Health check failed:', error);
                    statusText.textContent = 'API is unreachable.';
                    statusIndicator.className = 'w-4 h-4 rounded-full bg-red-500';
                }
            };
            
            checkApiHealth();
        });
    </script>
</body>
</html>
EOF
echo "  - nexusmind-web-ui/index.html created."
echo -e "${GREEN}✓ Frontend file created.${NC}"

# --- 5. Create GitHub Actions Workflow ---
echo -e "\n${YELLOW}[5/6] Creating GitHub Actions deployment workflow...${NC}"

cat << 'EOF' > .github/workflows/deploy.yml
name: Build and Deploy Nexus Node App

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    name: Build and Deploy to Droplet
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          # Using your Docker Hub username 'tssprotx' as requested
          tags: tssprotx/nexus-orchestrator:${{ github.sha }},tssprotx/nexus-orchestrator:latest

      - name: Deploy to Server via SSH
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.DO_SSH_HOST }}
          username: ${{ secrets.DO_SSH_USER }}
          key: ${{ secrets.DO_SSH_PRIVATE_KEY }}
          script: |
            # Define image name and container name
            IMAGE_NAME=tssprotx/nexus-orchestrator:latest
            CONTAINER_NAME=nexus-app

            # Log in to Docker Hub on the server
            echo "${{ secrets.DOCKERHUB_TOKEN }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin

            # Pull the latest image
            docker pull $IMAGE_NAME

            # Stop and remove the old container if it exists
            docker stop $CONTAINER_NAME || true
            docker rm $CONTAINER_NAME || true

            # Run the new container
            docker run -d \
              -p 80:3000 \
              --name $CONTAINER_NAME \
              --restart always \
              $IMAGE_NAME

            # Clean up old, unused Docker images
            docker image prune -af
EOF
echo "  - .github/workflows/deploy.yml created."
echo -e "${GREEN}✓ Deployment workflow created.${NC}"

# --- 6. Final Instructions ---
echo -e "\n${YELLOW}[6/6] Finalizing setup...${NC}"

echo -e "\n\n${BLUE}--- ✅ Project Scaffolding Complete! ---${NC}"
echo -e "Your project directory is now fully populated."
echo -e "\n${YELLOW}--- Next Steps ---${NC}"
echo "1. Initialize a Git repository: ${GREEN}git init && git add . && git commit -m 'Initial project structure'${NC}"
echo "2. Create a new repository on GitHub named 'nexus-orchestrator'."
echo "3. Link your local repo to GitHub and push your initial commit."
echo "4. Set up the required secrets (DOCKERHUB_USERNAME, etc.) in your GitHub repo settings."
echo "5. To test locally, run: ${GREEN}docker build -t nexus-local . && docker run -p 3000:3000 nexus-local${NC}"

