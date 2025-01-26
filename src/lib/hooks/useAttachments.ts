import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import type { Database } from '../../../migrations/catch-a-case-db'

type Attachment = Database['public']['Tables']['attachments']['Row']
type AttachmentWithUploader = Attachment & {
  uploader: {
    id: string
    full_name: string
    role: string
  }
}

interface MessageAttachmentResponse {
  attachment: Omit<AttachmentWithUploader, 'uploader'> & {
    uploader: Array<{
      id: string
      full_name: string
      role: string
    }>
  }
}

export function useAttachments(caseId: string) {
  return useQuery({
    queryKey: ['case-attachments', caseId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('attachments')
        .select(`
          *,
          uploader:uploader_id(
            id,
            full_name,
            role
          )
        `)
        .eq('case_id', caseId)
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as AttachmentWithUploader[]
    },
  })
}

export function useMessageAttachments(messageId: string) {
  return useQuery({
    queryKey: ['message-attachments', messageId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('message_attachments')
        .select(`
          attachment:attachment_id(
            id,
            file_name,
            file_path,
            file_size,
            file_type,
            case_id,
            created_at,
            updated_at,
            uploader_id,
            uploader:uploader_id(
              id,
              full_name,
              role
            )
          )
        `)
        .eq('message_id', messageId)

      if (error) throw error

      // Use type assertion to handle the nested structure
      const typedData = data as unknown as MessageAttachmentResponse[]
      return typedData.map(({ attachment }) => ({
        ...attachment,
        uploader: attachment.uploader[0]
      })) as AttachmentWithUploader[]
    },
  })
} 
