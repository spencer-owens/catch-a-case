import { useEffect } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'
import { useAuth } from '@/lib/hooks/useAuth'

export interface InternalNote {
  id: string
  case_id: string
  agent_id: string
  note_content: string
  created_at: string
  updated_at: string
}

export function useInternalNotes(caseId: string) {
  const { user } = useAuth()
  const queryClient = useQueryClient()

  // Fetch initial notes
  const { data: notes = [] } = useQuery({
    queryKey: ['internal_notes', caseId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('internal_notes')
        .select('*')
        .eq('case_id', caseId)
        .order('created_at', { ascending: true })

      if (error) throw error
      return data as InternalNote[]
    },
  })

  // Set up real-time subscription
  useEffect(() => {
    const channel = supabase
      .channel(`internal-notes-${caseId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'internal_notes',
          filter: `case_id=eq.${caseId}`,
        },
        (payload) => {
          const newNote = payload.new as InternalNote
          
          // Update React Query cache
          queryClient.setQueryData(['internal_notes', caseId], (old: InternalNote[] = []) => {
            return [...old, newNote]
          })

          // Show notification for others' notes
          if (newNote.agent_id !== user?.id) {
            toast('New Internal Note', {
              description: 'A new internal note has been added',
            })
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [caseId, user?.id, queryClient])

  // Add a new note
  const addNote = async (content: string) => {
    const { error } = await supabase.from('internal_notes').insert({
      case_id: caseId,
      agent_id: user?.id,
      note_content: content,
    })

    if (error) {
      toast.error('Error', {
        description: 'Failed to add note',
      })
      throw error
    }
  }

  return {
    notes,
    addNote,
  }
} 