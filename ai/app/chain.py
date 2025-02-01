from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from pydantic import BaseModel, Field
from typing import List, Optional
import os
import logging
from langfuse import Langfuse
import openai
from openai import OpenAIError
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Validate environment variables
required_env_vars = [
    "OPENAI_API_KEY",
    "LANGFUSE_PUBLIC_KEY",
    "LANGFUSE_SECRET_KEY"
]

missing_vars = [var for var in required_env_vars if not os.getenv(var)]
if missing_vars:
    raise EnvironmentError(f"Missing required environment variables: {', '.join(missing_vars)}")

# Initialize Langfuse
langfuse = Langfuse(
    public_key=os.getenv("LANGFUSE_PUBLIC_KEY"),
    secret_key=os.getenv("LANGFUSE_SECRET_KEY"),
    host=os.getenv("LANGFUSE_HOST", "https://us.cloud.langfuse.com")
)

# Output schema for the AI's response
class CaseAssignment(BaseModel):
    assigned_agent_id: str = Field(description="The email of the agent assigned to the case")
    confidence_score: float = Field(description="A score between 0 and 1 indicating confidence in the assignment")
    reasoning: str = Field(description="Detailed explanation of why this agent was chosen")
    tags: List[str] = Field(description="Suggested tags for the case")

# Initialize the language model
try:
    model = ChatOpenAI(
        model="gpt-4-turbo-preview",
        temperature=0
    )
except Exception as e:
    logger.error(f"Failed to initialize OpenAI model: {str(e)}")
    raise

# Create the prompt template
SYSTEM_PROMPT = """You are an AI assistant that helps assign cases to agents based on case descriptions.

Agent Rules:
- agent3@law.com: Specializes in car accidents only
- agent4@law.com: Handles all other personal injury cases (slip and fall, medical malpractice, etc.)

You must analyze the case and assign it to the most appropriate agent following these rules.
Your response must be a valid JSON object with these fields:
- assigned_agent_id: The agent's email
- confidence_score: Number between 0 and 1
- reasoning: Clear explanation for the assignment
- tags: Array of relevant case tags"""

USER_PROMPT_TEMPLATE = """Case Information:
Title: {title}
Description: {description}

Assign this case to the appropriate agent."""

prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    ("user", USER_PROMPT_TEMPLATE)
])

# Create the output parser
output_parser = JsonOutputParser(pydantic_object=CaseAssignment)

# Create the chain
chain = prompt | model | output_parser

class AIServiceError(Exception):
    """Custom exception for AI service errors"""
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

async def process_case(title: str, description: str, trace_id: Optional[str] = None) -> CaseAssignment:
    """Process a case and assign it to an agent based on hardcoded rules."""
    logger.info(f"Processing case - Title: {title}, Trace ID: {trace_id}")
    
    try:
        # Create a trace
        trace = langfuse.trace(
            name="case_assignment",
            id=trace_id,
            metadata={
                "title": title,
                "description_length": len(description)
            }
        )

        # Format the prompt with our input
        formatted_prompt = prompt.format_messages(
            title=title,
            description=description
        )

        # Create a generation that will track the LLM interaction
        generation = trace.generation(
            name="analyze_case",
            model="gpt-4-turbo-preview",
            model_parameters={"temperature": 0},
            input={
                "system_prompt": SYSTEM_PROMPT,
                "user_prompt": USER_PROMPT_TEMPLATE.format(
                    title=title,
                    description=description
                ),
                "raw_input": {
                    "title": title,
                    "description": description
                }
            }
        )

        try:
            # Run the chain
            result = await chain.ainvoke({
                "title": title,
                "description": description
            })

            # Convert result to dict if it's not already
            result_dict = result if isinstance(result, dict) else result.model_dump()

            # Update the generation with the output
            generation.end(
                output=result_dict,
                metadata={
                    "confidence_score": result_dict["confidence_score"],
                    "assigned_agent": result_dict["assigned_agent_id"],
                    "tags": result_dict["tags"]
                }
            )

            logger.info(f"Case processed successfully - Assigned to: {result_dict['assigned_agent_id']}")
            logger.info(f"Confidence score: {result_dict['confidence_score']}")
            logger.info(f"Tags: {result_dict['tags']}")
            
            return CaseAssignment(**result_dict)

        except Exception as e:
            # If chain execution fails, end the generation with error
            generation.end(
                output={"error": str(e)},
                metadata={"error": str(e)},
                level="error"
            )
            raise

    except OpenAIError as e:
        error_msg = f"OpenAI API error: {str(e)}"
        logger.error(error_msg)
        raise AIServiceError(error_msg, status_code=502)
        
    except Exception as e:
        error_msg = f"Error in case processing: {str(e)}"
        logger.error(error_msg, exc_info=True)
        raise AIServiceError(error_msg) 