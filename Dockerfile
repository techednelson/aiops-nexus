# Stage 1: Ollama service
FROM ollama/ollama:latest AS ollama

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

COPY app /aiops-nexus/app

EXPOSE 5000 11434

RUN echo '#!/bin/bash \n \
ollama serve & \n \
sleep 5 \n \
if ! ollama pull $LLM; then \n \
    echo "Failed to pull LLM, falling back to llama3.2:3b" \n \
    export LLM=llama3.2:3b \n \
    ollama pull $LLM \n \
fi \n \
echo "Running LLM: $LLM" \n \
python /aiops-nexus/app/main.py' > /aiops-nexus/entrypoint.sh && \
chmod +x /aiops-nexus/entrypoint.sh

ENTRYPOINT ["/aiops-nexus/entrypoint.sh"]
