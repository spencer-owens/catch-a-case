from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
from .chain import process_case, CaseAssignment, AIServiceError
import os
import logging
import time
from contextlib import asynccontextmanager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

# Validate CORS origins
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:5173").split(",")
logger.info(f"Configured CORS origins: {ALLOWED_ORIGINS}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting up AI service...")
    yield
    # Shutdown
    logger.info("Shutting down AI service...")

# Initialize FastAPI app
app = FastAPI(
    title="Case Assignment AI Service",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request model
class CaseRequest(BaseModel):
    title: str
    description: str

@app.middleware("http")
async def log_requests(request: Request, call_next):
    # Generate request ID
    request_id = f"req-{time.time_ns()}"
    
    # Log request
    logger.info(f"Request {request_id} started: {request.method} {request.url.path}")
    
    # Time the request
    start_time = time.time()
    try:
        response = await call_next(request)
        process_time = time.time() - start_time
        
        logger.info(
            f"Request {request_id} completed: {response.status_code} "
            f"(took {process_time:.2f}s)"
        )
        return response
    except Exception as e:
        process_time = time.time() - start_time
        logger.error(
            f"Request {request_id} failed after {process_time:.2f}s: {str(e)}",
            exc_info=True
        )
        raise

# Health check endpoint
@app.get("/health")
async def health_check():
    logger.info("Health check endpoint called")
    return {"status": "healthy"}

# Root endpoint
@app.get("/")
async def root():
    logger.info("Root endpoint called")
    return {"message": "Welcome to the Case Assignment AI Service"}

# Error handler for AIServiceError
@app.exception_handler(AIServiceError)
async def ai_service_error_handler(request: Request, exc: AIServiceError):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.message}
    )

# Case assignment endpoint
@app.post("/assign", response_model=CaseAssignment)
async def assign_case(case: CaseRequest, request: Request):
    trace_id = request.headers.get("x-trace-id")
    logger.info(f"Processing case assignment request. Trace ID: {trace_id}")
    logger.info(f"Case details - Title: {case.title}")
    
    try:
        result = await process_case(
            title=case.title,
            description=case.description,
            trace_id=trace_id
        )
            
        logger.info(f"Case assigned successfully. Agent: {result.assigned_agent_id}")
        return result
    except AIServiceError as e:
        logger.error(f"AI service error: {e.message}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="An unexpected error occurred") 