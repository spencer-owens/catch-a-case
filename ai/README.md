# Case Assignment AI Service

This service provides AI-powered case assignment functionality for the Catch a Case application. It analyzes case descriptions and automatically assigns them to the most appropriate agent based on their specialization.

## Features

- Automatic case assignment based on case description analysis
- Integration with LangFuse for observability and model performance tracking
- Asynchronous processing with status updates
- Detailed explanations for assignment decisions

## Local Development

1. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your API keys:
# OPENAI_API_KEY=your-openai-api-key
# LANGFUSE_PUBLIC_KEY=your-langfuse-public-key
# LANGFUSE_SECRET_KEY=your-langfuse-secret-key
# LANGFUSE_HOST=https://us.cloud.langfuse.com
```

4. Run the service:
```bash
uvicorn app.server:app --reload --port 8000
```

The service will be available at `http://localhost:8000`.

## Deployment

This service can be deployed to platforms like Railway or Vercel:

1. Connect your repository
2. Set the environment variables in the platform's UI
3. Set the build command: `pip install -r requirements.txt`
4. Set the start command: `uvicorn app.server:app --host 0.0.0.0 --port $PORT`

## API Endpoints

### POST /assign-case

Assigns a case to an agent based on the case description.

Request body:
```json
{
  "description": "string",
  "trace_id": "string" (optional)
}
```

Response:
```json
{
  "agent_email": "string",
  "explanation": "string"
}
```

### GET /health

Health check endpoint.

Response:
```json
{
  "status": "healthy"
}
```

## Monitoring and Observability

The service uses LangFuse for monitoring and observability. You can view metrics, traces, and annotations in the LangFuse dashboard. 