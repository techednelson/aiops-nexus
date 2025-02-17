# Stage 1: Python builder image
FROM python:3.11-slim-bullseye AS builder

WORKDIR /unhealthy-app

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    VIRTUAL_ENV=/unhealthy-app/.venv

# Copy only necessary files
COPY pyproject.toml poetry.lock README.md ./
# Cache dependencies for dasters builds
RUN --mount=type=cache,target=/root/.cache/pip pip install poetry==2.0.1
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --only main --no-root

# Stage 3: Runtime
FROM python:3.11-slim-bullseye AS runtime

WORKDIR /unhealthy-app

ENV VIRTUAL_ENV=/unhealthy-app/.venv \
    PATH="/unhealthy-app/.venv/bin:$PATH" \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_ORIGINS=*

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY app /unhealthy-app/app

EXPOSE 8080

ENTRYPOINT ["python" , "/unhealthy-app/app/main.py"]
