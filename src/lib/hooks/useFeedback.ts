import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'

interface FeedbackData {
  rating: number
  comments?: string
}

export function useFeedback(caseId: string) {
  const queryClient = useQueryClient()

  const { data: feedback, isLoading } = useQuery({
    queryKey: ['feedback', caseId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('feedback')
        .select('*')
        .eq('case_id', caseId)
        .maybeSingle()

      if (error) throw error
      return data
    },
  })

  const submitFeedback = useMutation({
    mutationFn: async (data: FeedbackData) => {
      const { error } = await supabase
        .from('feedback')
        .upsert({
          case_id: caseId,
          client_id: (await supabase.auth.getUser()).data.user!.id,
          rating: data.rating,
          comments: data.comments,
        })

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['feedback', caseId] })
    },
  })

  return {
    feedback,
    isLoading,
    submitFeedback: submitFeedback.mutate,
    isSubmitting: submitFeedback.isPending,
  }
} 