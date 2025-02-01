import { type CaseAssignmentResponse } from '@/types/ai'

const AI_SERVICE_URL = import.meta.env.VITE_AI_SERVICE_URL || 'http://localhost:8000';

function generateTraceId(): string {
  return `trace-${Math.random().toString(36).substring(2, 15)}-${Date.now()}`;
}

export async function assignCase(title: string, description: string): Promise<CaseAssignmentResponse> {
  const traceId = generateTraceId();
  console.log('🤖 Calling AI service with:', { title, description, traceId });
  console.log('🌐 Using AI service URL:', AI_SERVICE_URL);

  try {
    const response = await fetch(`${AI_SERVICE_URL}/assign`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-trace-id': traceId,
      },
      body: JSON.stringify({
        title,
        description,
      }),
    });

    console.log('📡 AI service response status:', response.status);

    if (!response.ok) {
      const errorData = await response.json();
      console.error('❌ AI service error:', errorData);
      throw new Error(errorData.detail || `AI service error: ${response.statusText}`);
    }

    const data = await response.json();
    console.log('✅ AI service response:', data);
    return data;
  } catch (error) {
    console.error('🚨 Error calling AI service:', error);
    throw error;
  }
} 