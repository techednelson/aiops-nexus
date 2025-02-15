# AIOps Nexus

<img src="https://github.com/techednelson/aiops-nexus/images/aiops-nexus.jpg" width="100">

## Quickstart

### Docker
***Ideal for fast deployment and testing locally.***
```
docker run --name aiops-nexus -p 5000:5000 webtechnelson/aiops-nexus:latest
```
```
curl -X POST http://localhost:5000/aiops/alert \
-H "Content-Type: application/json" \
-d '{"ERROR": "10.185.248.71 - - [09/Jan/2015:19:12:06 +0000] 808840 \"GET inventoryService/inventory/purchaseItem? userId=20253471&itemId=23434300 HTTP/1.1\" 500 17 \"-\" \"Apache-HttpClient/4.2.6 (java 1.5)\""}'

```
### Docker Compose (Integration with Open-Webui)
***Ideal for an easy and fast deployment locally and in VMs with controlled access, recommended for companies interested in keep prompts and gpt responses inside a VPN without accesing the internet. You can use this set up for AIOps and Interact directly with ollama LLMs via the open-webui userfriendly interface.***
```
services:
  aiops-nexus:
    container_name: aiops-nexus
    image: webtechnelson/aiops-nexus:latest
    working_dir: /aiops-nexus
    command: ./aiops-nexus/entrypoint.sh
    environment:
      DEBUG: 1
      WEBHOOK_URL: https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    volumes:
      - ./app:/aiops-nexus/app
    ports:
      - "5000:5000"
      - "11434"
    restart: on-failure
  open-webui:
    container_name: open-webui
    image: ghcr.io/open-webui/open-webui:main
    environment:
      - OLLAMA_BASE_URL=http://aiops-nexus:11434
    volumes:
      - open-webui:/app/backend/data
    ports:
      - "3000:8080"
    restart: always

volumes:
  open-webui:
```
- http://localhost:3000 go to open-webui
- Enter any value in `Full Name`, `Email` & `password` to signup

## Examples

### Nexus-AIOps & Opensearch (kubernetes setup)

- Folder: examples/opensearch

### Nexus-AIOps & Elasticsearch (docker-compose setup)

- Folder: examples/elasticsearch

