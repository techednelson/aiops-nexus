# AIOps-Nexus

<p align="center">
  <img src="./images/aiops-nexus.jpg" alt="name"/>
<p/>

----

**AIOps-Nexus** is an open-source, **dockerized application** that simplifies IT operations by analyzing logs from monitoring tools like **OpenSearch**, **Elasticsearch**, **Alertmanager**, **Prometheus**, and more. Using free, open-source LLMs, it identifies root causes of issues and generates actionable solutions.

Deployable within your corporate infrastructure (e.g., inside a VPN) or on cloud VMs with controlled access, AIOps-Nexus ensures your data remains secure and never exposed to the internet. This makes it ideal for organizations prioritizing privacy while leveraging AI to enhance operational efficiency with **minimal costs**, limited to the hardware or VM where it is deployed.

---

## Key Features

- **[Dynamic LLM Selection](https://ollama.com/search)**: Choose from various open-source LLMs (e.g., Llama 3, Mistral, DeepSeek-R1, and more via Ollama) to meet specific user needs.
- **Free and Open Source**: Utilize completely free, open-source LLM models without incurring API costs—your only expense is the hardware or VM where the app is deployed.
- **Log Analysis**: Automatically analyze logs from monitoring tools to identify root causes of incidents.
- **Actionable Solutions**: Generate and deliver solutions via webhooks to platforms like Slack and Discord for team awareness and collaboration.
- **Caching Mechanism**: Optimize performance by caching repeated queries for faster responses.

## Why Use AIOps-Nexus?

**AIOps-Nexus** enables companies and users to integrate AI into their operations effortlessly, supporting incident resolution and operational efficiency at no additional cost beyond infrastructure. By combining cutting-edge AI with a user-friendly interface, this project empowers teams to focus on solving problems rather than managing tools.

## To start using AIOps-Nexu

### Docker
**Ideal for fast deployment and local testing.**
```
docker run --name aiops-nexus LLM=llama3.2 -p 5000:5000 webtechnelson/aiops-nexus:latest
```
Test **AIOps nexus** api with:
```
curl -X POST http://localhost:5000/aiops/alert \
-H "Content-Type: application/json" \
-d '{"ERROR": "10.185.248.71 - - [09/Jan/2015:19:12:06 +0000] 808840 \"GET inventoryService/inventory/purchaseItem? userId=20253471&itemId=23434300 HTTP/1.1\" 500 17 \"-\" \"Apache-HttpClient/4.2.6 (java 1.5)\""}'

```
### Docker Compose (Integration with Open-Webui)
**Ideal for quick deployment on Cloud VMs with controlled access or VMs in a corporate envinment within a VPN. Perfect for companies looking to keep prompts and GPT responses secure without internet exposure. Use it for AIOps log analysis or interact directly with Ollama LLMs through a user-friendly Open-WebUI for technical consultations.**
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
Test **AIOps nexus** api with:
```
curl -X POST http://localhost:5000/aiops/alert \
-H "Content-Type: application/json" \
-d '{"ERROR": "10.185.248.71 - - [09/Jan/2015:19:12:06 +0000] 808840 \"GET inventoryService/inventory/purchaseItem? userId=20253471&itemId=23434300 HTTP/1.1\" 500 17 \"-\" \"Apache-HttpClient/4.2.6 (java 1.5)\""}'

```

Access Open-WebUI at [http://localhost:3000](http://localhost:3000).

- Enter any value in `Full Name`, `Email`, and `Password` fields to sign up.

---

## Examples

### Nexus-AIOps: Integration with OpenSearch (Kubernetes Setup)
- Follow detailed instructions here: [`examples/opensearch/README.md`](./examples/opensearch/README.md)

### Nexus-AIOps: Elasticsearch Integration (Docker Compose Setup)
- Follow detailed instructions here: [`examples/elasticsearch/README.md`](./examples/elasticsearch/README.md)


---

## Get Involved

We welcome contributors! Whether you're a developer, DevOps engineer, SRE, or AI enthusiast, join us in building the future of AIOps. Check out our repository and start contributing today!


