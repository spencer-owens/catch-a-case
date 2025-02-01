from langchain_openai import ChatOpenAI
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
import os

llm = ChatOpenAI(model="gpt-4o-mini")

_TEMPLATE = "Answer the following question as best you can, and end the question with a follow up question: {question}"

prompt = PromptTemplate.from_template(_TEMPLATE)

chain = prompt | llm | StrOutputParser()
