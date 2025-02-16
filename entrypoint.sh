#!/bin/bash

# Start Ollama server in the background
ollama serve &

# Wait for the server to start
sleep 5

# Check if LLM is not set or if pulling the specified model fails
if [[ -z "$LLM" || ! $(ollama pull "$LLM") ]]; then
    echo "LLM was not set or invalid, falling back to pre-installed model llama3.2"
    export LLM=llama3.2
fi

echo "Running LLM: $LLM"

# Start the FastAPI application
python /aiops-nexus/app/main.py
