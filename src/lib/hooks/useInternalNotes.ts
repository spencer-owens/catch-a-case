import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
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
  const [newNotes, setNewNotes] = useState<InternalNote[]>([])

  // Fetch initial notes
  const { data: notes = [], refetch } = useQuery({
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
      .channel('internal-notes-channel')
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
          setNewNotes((prev) => [...prev, newNote])
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
  }, [caseId, user?.id])

  // Add a new note
  const addNote = async (content: string) => {
    const { error } = await supabase.from('internal_notes').insert({
      case_id: caseId,
      agent_id: user?.id,
      note_content: content,
    })

    if (error) {
      toast.error('Error', {
        description: 'Failed to add internal note',
      })
      throw error
    }
  }

  // Combine and sort all notes
  const allNotes = [...notes, ...newNotes].sort(
    (a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  )

  return {
    notes: allNotes,
    addNote,
    isLoading: false,
  }
} 