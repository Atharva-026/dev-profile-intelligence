#!/bin/bash
echo "Starting Kestra..."
docker rm -f kestra 2>/dev/null

source /workspaces/dev-profile-intelligence/.secrets

docker run --pull=always -d -p 8080:8080 --user=root --name kestra \
  -v kestra_data:/app/storage \
  -e SECRET_GITHUB_TOKEN=$SECRET_GITHUB_TOKEN \
  -e SECRET_GROQ_API_KEY=$SECRET_GROQ_API_KEY \
  -e SECRET_GMAIL_ADDRESS=$SECRET_GMAIL_ADDRESS \
  -e SECRET_GMAIL_PASSWORD=$SECRET_GMAIL_PASSWORD \
  kestra/kestra:latest server local

echo "Waiting for Kestra to start..."
sleep 90

echo "Importing flow..."
curl -X POST http://localhost:8080/api/v1/main/flows \
  -H "Content-Type: application/x-yaml" \
  --data-binary @/workspaces/dev-profile-intelligence/flows/dev-profile-intelligence.yml

echo "Done! Starting dashboard..."
node /workspaces/dev-profile-intelligence/server.js
