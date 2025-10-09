##BUILD STAGGE
FROM python:3.12 AS build

#Install uv packages
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/


#set workingg directory
WORKDIR /app
COPY pyproject.toml ./

#install dependencies
RUN uv sync --no-install-project --no-editable

#copy requirements file
COPY cc_simple_server/ /app/cc_simple_server/

RUN uv sync --no-editable

#FINAL STAGE
FROM python:3.12-slim AS final

#COPY The virtual env from the build stage
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

#Copy tests directory into final stage
WORKDIR /app

#copy the app files
COPY --from=build /app/.venv /app/.venv




#create non-root user


#epose port 8000
EXPOSE 8000

#set CMD to run the FAST API SERVER on 0.0.0.0:8000
CMD ["uvicorn", "cc_simple_server.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]