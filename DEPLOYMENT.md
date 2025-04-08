# Local Deployment

# Run locally:

```
cd socialAIzation
cp env.example .env
docker compose build
docker compose up
```

This will provide the following endpoints:
* UI -  http://localhost:5000/
* API - Example: http://localhost:5001/api/scenarios
* Conversation API - http://localhost:5002/docs

## Publish container images

```
REGISTRY= # e.g. docker.io/lastcoolnameleft
VERSION=0.0.3

# Build
docker build -t $REGISTRY/socialaization-conv-api:$VERSION --platform linux/amd64 ConversationAPI/backend
docker build -t $REGISTRY/socialaization-be:$VERSION --platform linux/amd64 App/backend
docker build -t $REGISTRY/socialaization-fe:$VERSION --platform linux/amd64 App/frontend

#  Publish
docker push $REGISTRY/socialaization-conv-api:$VERSION
docker push $REGISTRY/socialaization-be:$VERSION
docker push $REGISTRY/socialaization-fe:$VERSION
```

## Deploy to Azure via Tofu:

This assumes you have the following:

* Scenario UI + API and Conversation API containers in a container registry (see above step)

```
cd infrastructure/azure/opentofu

# Copy the example and Replace with your own configurations (e.g. storage accounts are globally unique)
cp example-backend-configs/backend-dev.conf backend-dev.conf

# Create the execution plan (verify no errors or warnings)
tofu plan -var-file backend-dev.conf

# Apply the execution plan
tofu apply -var-file backend-dev.conf

# Add a model to your AI Foundry Project
# https://learn.microsoft.com/en-us/azure/ai-foundry/model-inference/how-to/create-model-deployments?pivots=ai-foundry-portal
# Update backend-dev.conf settings:
azure_openai_api_key             = "..."
azure_openai_deployment_name     = "..."
azure_openai_api_version         = "..."
azure_openai_endpoint            = "https://....openai.azure.com/"

# Apply the execution plan
tofu apply -var-file backend-dev.conf

# Cleanup 
tofu destroy -var-file backend-dev.conf
```

