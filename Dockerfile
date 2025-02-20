# Stage 1: Ollama service
FROM ollama/ollama:latest AS ollama

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Download and install wait4x
RUN curl -#LO https://github.com/atkrad/wait4x/releases/latest/download/wait4x-linux-amd64.tar.gz && \
    tar --one-top-level -xvf wait4x-linux-amd64.tar.gz && \
    mv ./wait4x-linux-amd64/wait4x /usr/local/bin/wait4x && \
    chmod +x /usr/local/bin/wait4x && \
    rm -rf wait4x-linux-amd64.tar.gz wait4x-linux-amd64

# Start ollama server, wait4x to be ready and preinstall llama3,2 as default LLM
RUN nohup bash -c "ollama serve &" && wait4x http http://127.0.0.1:11434 && ollama pull llama3.2

# Stage 2: Python builder image
FROM python:3.11-slim-bullseye AS builder

WORKDIR /aiops-nexus

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    VIRTUAL_ENV=/aiops-nexus/.venv

# Copy only necessary files
COPY pyproject.toml poetry.lock README.md ./
# Cache dependencies for dasters builds
RUN --mount=type=cache,target=/root/.cache/pip pip install poetry==2.0.1
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --only main --no-root

# Stage 3: Runtime
FROM python:3.11-slim-bullseye AS runtime

WORKDIR /aiops-nexus

ENV VIRTUAL_ENV=/aiops-nexus/.venv \
    PATH="/aiops-nexus/.venv/bin:$PATH" \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_ORIGINS=*

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
COPY --from=ollama /usr/bin/ollama /usr/bin/ollama
COPY --from=ollama /usr/lib/ollama /usr/lib/ollama
COPY --from=ollama /root/.ollama /root/.ollama

COPY app /aiops-nexus/app

EXPOSE 5000 11434

# Create the entrypoint script
RUN echo '#!/bin/bash \n \
ollama serve & \n \
echo "Running LLM: $LLM" \n \
sleep 5 \n \
set_default_llm () { \n \
    echo "LLM was not set or invalid, falling back to pre-installed model llama3.2" \n \
    export LLM=llama3.2 \n \
} \n \
if [[ -z "$LLM" ]]; then \n \
    set_default_llm \n \
else \n \
    if ! ollama pull "$LLM"; then \n \
        set_default_llm \n \
    fi \n \
fi \n \
echo "Running LLM: $LLM" \n \
python /aiops-nexus/app/main.py' > /aiops-nexus/entrypoint.sh && \
chmod +x /aiops-nexus/entrypoint.sh


ENTRYPOINT ["/aiops-nexus/entrypoint.sh"]
