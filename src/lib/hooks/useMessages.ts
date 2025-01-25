import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
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
  const [newMessages, setNewMessages] = useState<Message[]>([])

  // Fetch initial messages
  const { data: messages = [], refetch } = useQuery({
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
      
      // Transform the data to include case_agent_id
      return data.map((message: any) => ({
        ...message,
        case_agent_id: message.cases.assigned_agent_id
      })) as Message[]
    },
  })

  // Set up real-time subscription
  useEffect(() => {
    const channel = supabase
      .channel('messages-channel')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `case_id=eq.${caseId}`,
        },
        (payload) => {
          const newMsg = payload.new as Message
          setNewMessages((prev) => [...prev, newMsg])
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
  }, [caseId, user?.id])

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

  // Combine and sort all messages
  const allMessages = [...messages, ...newMessages].sort(
    (a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
  )

  return {
    messages: allMessages,
    sendMessage,
    isLoading: false,
  }
} 