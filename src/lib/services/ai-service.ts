import { type CaseAssignmentResponse } from '@/types/ai'

const AI_SERVICE_URL = import.meta.env.VITE_AI_SERVICE_URL || 'http://localhost:8000'

export async function getAIAssignment(title: string, description: string): Promise<CaseAssignmentResponse> {
  try {
    const response = await fetch(`${AI_SERVICE_URL}/assign`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title,
        description,
      }),
    })

    if (!response.ok) {
      throw new Error(`AI Service error: ${response.statusText}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error('Error getting AI assignment:', error)
    throw error
  }
} 