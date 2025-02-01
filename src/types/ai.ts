export interface CaseAssignmentResponse {
  assigned_agent_id: string
  confidence_score: number
  reasoning: string
  tags: string[]
}

export interface AIError {
  detail: string
} 