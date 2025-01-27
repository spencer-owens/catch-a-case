import { useEffect } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'
import { useAuth } from '@/lib/hooks/useAuth'

export interface Message {
  id: string
  case_id: string
  sender_id: string
  message_content: string
  created_at: string
  updated_at: string
  case_agent_id?: string // Optional since it comes from a join
}

export function useMessages(caseId: string) {
  const { user } = useAuth()
  const queryClient = useQueryClient()

  // Fetch initial messages
  const { data: messages = [] } = useQuery({
    queryKey: ['messages', caseId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('messages')
        .select(`
          *,
          cases!inner (
            assigned_agent_id
          )
        `)
        .eq('case_id', caseId)
        .order('created_at', { ascending: true })

      if (error) throw error
      
      return data.map((message: any) => ({
        ...message,
        case_agent_id: message.cases.assigned_agent_id
      })) as Message[]
    },
  })

  // Set up real-time subscription
  useEffect(() => {
    const channel = supabase
      .channel(`messages-${caseId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `case_id=eq.${caseId}`,
        },
        async (payload) => {
          const newMsg = payload.new as Message
          
          // Fetch the complete message data including the case_agent_id
          const { data, error } = await supabase
            .from('messages')
            .select(`
              *,
              cases!inner (
                assigned_agent_id
              )
            `)
            .eq('id', newMsg.id)
            .single()

          if (error) {
            console.error('Error fetching complete message:', error)
            return
          }

          // Update React Query cache
          queryClient.setQueryData(['messages', caseId], (old: Message[] = []) => {
            const newMessage = {
              ...data,
              case_agent_id: data.cases.assigned_agent_id
            }
            return [...old, newMessage]
          })

          // Show notification for others' messages
          if (newMsg.sender_id !== user?.id) {
            toast('New Message', {
              description: 'You have received a new message',
            })
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [caseId, user?.id, queryClient])

  // Send a new message
  const sendMessage = async (content: string) => {
    const { error } = await supabase.from('messages').insert({
      case_id: caseId,
      sender_id: user?.id,
      message_content: content,
    })

    if (error) {
      toast.error('Error', {
        description: 'Failed to send message',
      })
      throw error
    }
  }

  return {
    messages,
    sendMessage,
    isLoading: false,
  }
} 