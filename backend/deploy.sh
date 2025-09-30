#!/bin/bash

# CocoaHeads Backend Deployment Script
# This script pulls the latest code and rebuilds the backend service

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting CocoaHeads Backend Deployment...${NC}"

# Load deployment configuration if exists
if [ -f .env.deploy ]; then
    source .env.deploy
fi

# Default values
REPO_DIR=${REPO_DIR:-"/home/ubuntu/CHConferenceApp"}
DEPLOY_BRANCH=${DEPLOY_BRANCH:-"develop"}

echo -e "${YELLOW}Repository: ${REPO_DIR}${NC}"
echo -e "${YELLOW}Branch: ${DEPLOY_BRANCH}${NC}"

# Navigate to repository root
cd "${REPO_DIR}"

# Fetch and pull latest changes
echo -e "${YELLOW}Fetching latest changes...${NC}"
git fetch

echo -e "${YELLOW}Pulling from ${DEPLOY_BRANCH}...${NC}"
git pull origin "${DEPLOY_BRANCH}"

# Navigate to backend directory
cd backend

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Stop existing containers gracefully
echo -e "${YELLOW}Stopping existing containers...${NC}"
sudo docker compose down || true

# Rebuild and start containers
echo -e "${YELLOW}Building and starting containers...${NC}"
sudo docker compose up -d --build

# Wait for containers to be healthy
echo -e "${YELLOW}Waiting for containers to start...${NC}"
sleep 5

# Check container status
if sudo docker compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo -e "${GREEN}✓ Backend is now running${NC}"
    sudo docker compose ps
else
    echo -e "${RED}✗ Deployment failed - containers are not running${NC}"
    sudo docker compose logs --tail=50
    exit 1
fi

echo -e "${GREEN}Deployment completed at $(date)${NC}"
