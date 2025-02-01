import { useState } from 'react';
import { assignCase } from '@/lib/ai-client';
import { useToast } from '@/components/ui/use-toast';
import { supabase } from '@/lib/supabase';

interface UseAIAssignmentResult {
  isAssigning: boolean;
  assignCaseToAgent: (caseId: string, title: string, description: string) => Promise<void>;
  error: Error | null;
}

export function useAIAssignment(): UseAIAssignmentResult {
  const [isAssigning, setIsAssigning] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const { toast } = useToast();

  const assignCaseToAgent = async (caseId: string, title: string, description: string) => {
    console.log('🎯 Starting case assignment process:', { caseId, title, description });
    setIsAssigning(true);
    setError(null);

    try {
      // Get AI assignment
      console.log('📤 Requesting AI assignment...');
      const assignment = await assignCase(title, description);
      console.log('📥 Received AI assignment:', JSON.stringify(assignment, null, 2));

      // Look up the agent's ID by email
      console.log('🔍 Looking up agent ID for email:', assignment.assigned_agent_id);
      const { data: agentData, error: agentError } = await supabase
        .from('users')
        .select('id, email, role')
        .eq('email', assignment.assigned_agent_id)
        .single();

      console.log('🔎 Agent lookup result:', { data: agentData, error: agentError });

      if (agentError) {
        console.error('❌ Error finding agent:', agentError);
        throw new Error(`Could not find agent with email ${assignment.assigned_agent_id}`);
      }

      if (!agentData) {
        console.error('❌ No agent found with email:', assignment.assigned_agent_id);
        throw new Error(`No agent found with email ${assignment.assigned_agent_id}`);
      }

      console.log('✅ Found agent:', {
        id: agentData.id,
        email: agentData.email,
        role: agentData.role
      });

      // Get current case data
      console.log('🔍 Fetching current case data...');
      const { data: currentCase, error: fetchError } = await supabase
        .from('cases')
        .select('*')
        .eq('id', caseId)
        .single();

      if (fetchError) {
        console.error('❌ Error fetching case:', fetchError);
        throw fetchError;
      }

      console.log('📋 Current case data:', JSON.stringify(currentCase, null, 2));

      // Prepare update payload
      const updatePayload = {
        assigned_agent_id: agentData.id,
        custom_fields: {
          ...(currentCase?.custom_fields || {}),
          ai_assignment_explanation: assignment.reasoning,
          ai_confidence_score: assignment.confidence_score,
          case_tags: assignment.tags
        }
      };

      console.log('📝 Preparing update with payload:', JSON.stringify(updatePayload, null, 2));

      // Update case in Supabase (without nested select)
      console.log('💾 Updating case with AI assignment...');
      const { error: updateError } = await supabase
        .from('cases')
        .update(updatePayload)
        .eq('id', caseId);

      if (updateError) {
        console.error('❌ Error updating case:', updateError);
        throw updateError;
      }

      // Fetch the updated case to confirm changes
      console.log('🔍 Fetching updated case data...');
      const { data: updatedCase, error: refetchError } = await supabase
        .from('cases')
        .select('*, assigned_agent:assigned_agent_id(id, email)')
        .eq('id', caseId)
        .single();

      if (refetchError) {
        console.error('❌ Error fetching updated case:', refetchError);
        throw refetchError;
      }

      console.log('✅ Case successfully updated:', {
        caseId,
        newAgentId: updatedCase.assigned_agent_id,
        newAgentEmail: updatedCase.assigned_agent?.email,
        updatedCase
      });

      toast({
        title: 'Case Assigned',
        description: `Case has been assigned to ${assignment.assigned_agent_id}`,
      });
    } catch (err) {
      const error = err as Error;
      console.error('🚨 Assignment process failed:', {
        error,
        message: error.message,
        stack: error.stack
      });
      setError(error);
      toast({
        title: 'Assignment Failed',
        description: error.message,
        variant: 'destructive',
      });
    } finally {
      setIsAssigning(false);
    }
  };

  return {
    isAssigning,
    assignCaseToAgent,
    error,
  };
} 