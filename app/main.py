"""The entrypoint for the app"""

import logging
import os
import json
import requests
import uvicorn
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from langchain_core.caches import InMemoryCache
from langchain_core.globals import set_llm_cache
from langchain_ollama import ChatOllama
from pydantic import BaseModel

# Initialize Redis cache
# redis_cache = RedisCache(redis_url="redis://localhost:6379", ttl=3600)  # TTL is optional
# set_llm_cache(redis_cache)

# Set up the cache
set_llm_cache(InMemoryCache())

# Initialize Ollama with caching
llm = ChatOllama(
    model=os.environ.get("LLM"),
    cache=True,
    temperature=0.2,
)

app = FastAPI()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class AlertResponse(BaseModel):
    """The model describing the response for each alert"""
    status: str
    message: str

@app.post("/api/alert", response_model=AlertResponse)
async def receive_alert(request: Request) -> JSONResponse:
    """Rest endpoint to handle alerts sent by monitoring tool and to be anilsed by ollama llms"""
    try:
        alert_data = await request.json()
        # Log the received alert data for debugging purposes
        logger.info("Received alert:  %s", alert_data)
        messages = [
            (
                "system",
                "You are a Senior DevOps and SRE Engineer and you are receiving logs from several monitoring tools like opensearch, kibana, prometheous among others in JSON converted to string. Analyze the alert message, provide possible solutions and fixes for the logs send by the alert and return using less than 1900 characters, because Discord, slack and teams limit is this. Here is the  aler data for you to analyse and provide insights and fixes.",
            ),
            ("human", str(alert_data)),
        ]
        model_analysis = llm.invoke(messages).content

        # Handle potential issues with model API response
        if model_analysis is None:
            logger.info("No analysis available")

        logger.info("Model analysis:  %s", model_analysis)

        webhook_url = os.environ.get("WEBHOOK_URL")
        if webhook_url is not None:
            key = "text" if "slack" in webhook_url else "content"
            # Format the message for webhook
            webhook_message = json.dumps({key: model_analysis})
            # Send to webhook url
            webhook_response = requests.post(
                webhook_url,
                headers={"Content-Type": "application/json"},
                data=webhook_message,
                timeout=2.50
            )
            return AlertResponse(
                status="success",
                message=f"Alert received, processed and sent to webhook: {webhook_response.text}"
            )

        return AlertResponse(
            status="success",
            message=f"Alert received and analized: {model_analysis}"
        )

    except Exception as e:
        logger.error("Error processing alert:  %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


if __name__ == '__main__':
    env = os.environ.get("ENV", "production")
    uvicorn.run("main:app", host='0.0.0.0', port=5000, reload=env == "development")
