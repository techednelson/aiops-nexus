# AIOps-Nexus

<img src="https://github.com/techednelson/aiops-nexus/blob/main/images/aiops-nexus.jpg" width="100">

----

AIOps-Nexus is an open-source, **dockerized application** designed to revolutionize IT operations by leveraging **free, open-source LLMs** for root cause analysis and solution generation. This tool integrates seamlessly with popular monitoring systems like **OpenSearch**, **Elasticsearch**, **Alertmanager**, **Prometheus** and more, enabling organizations to harness the power of AI where the only expense is the hardware or VM where the app is deployed.

## Key Features

- **[Dynamic LLM Selection](https://ollama.com/searchp)**: Choose from various open-source LLMs (e.g. llama3, mistral, deepseek-r1 and much more available via Ollama) to meet specific user needs.
- **Free and Open Source**: Utilize completely free, open-source LLM models without incurring API costs—your where the only expense is the hardware or VM where the app is deployed.
- **Log Analysis**: Automatically analyze logs from monitoring tools to identify root causes of incidents.
- **Actionable Solutions**: Generate and deliver solutions via webhooks to platforms like Slack and Discord for team awareness and collaboration.
- **Caching Mechanism**: Optimize performance by caching repeated queries.

## Why Use AIOps-Nexus?

AIOps-Nexus enables companies and users to integrate AI into their operations effortlessly, supporting incident resolution and operational efficiency at no additional cost beyond infrastructure. By combining cutting-edge AI with a user-friendly interface, this project empowers teams to focus on solving problems rather than managing tools.

## Get Involved
We welcome contributors! Whether you're a developer, DevOps engineer, SRE, or AI enthusiast, join us in building the future of AIOps. Check out our repository and start contributing today!

## To start using AIOps-Nexu

### Docker
**Ideal for fast deployment and testing locally.**
```
docker run --name aiops-nexus LLM=llama3.2 -p 5000:5000 webtechnelson/aiops-nexus:latest
```
```
curl -X POST http://localhost:5000/aiops/alert \
-H "Content-Type: application/json" \
-d '{"ERROR": "10.185.248.71 - - [09/Jan/2015:19:12:06 +0000] 808840 \"GET inventoryService/inventory/purchaseItem? userId=20253471&itemId=23434300 HTTP/1.1\" 500 17 \"-\" \"Apache-HttpClient/4.2.6 (java 1.5)\""}'

```
### Docker Compose (Integration with Open-Webui)
**Ideal for quick and easy deployment locally or on VMs with controlled access, This AIOps-Nexus setup is perfect for companies looking to keep prompts and GPT responses secure within a VPN, without internet exposure. Use it for AIOps log analysis and/or interact directly with Ollama LLMs through a user-friendly Open-WebUI for technical consultations.**
```
services:
  aiops-nexus:
    container_name: aiops-nexus
    image: webtechnelson/aiops-nexus:latest
    working_dir: /aiops-nexus
    environment:
      DEBUG: 1
      WEBHOOK_URL: https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      LLM: llama3.2
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

