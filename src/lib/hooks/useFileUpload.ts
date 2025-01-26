import { useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { v4 as uuidv4 } from 'uuid'

interface FileUploadOptions {
  caseId: string
  messageId?: string
}

interface UploadResult {
  id: string
  file_name: string
  file_path: string
  file_size: number
  file_type: string
}

export function useFileUpload() {
  const [isUploading, setIsUploading] = useState(false)
  const [progress, setProgress] = useState(0)
  const queryClient = useQueryClient()

  const generateFilePath = (file: File) => {
    const timestamp = new Date().getTime()
    const uuid = uuidv4()
    const extension = file.name.split('.').pop()
    return `${timestamp}-${uuid}.${extension}`
  }

  const uploadFile = async (file: File, { caseId, messageId }: FileUploadOptions) => {
    try {
      setIsUploading(true)
      setProgress(0)

      const filePath = generateFilePath(file)

      // Upload to Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('attachments')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) throw uploadError

      // Create attachment record
      const { data: attachment, error: attachmentError } = await supabase
        .from('attachments')
        .insert({
          case_id: caseId,
          file_name: file.name,
          file_path: filePath,
          file_size: file.size,
          file_type: file.type,
          uploader_id: (await supabase.auth.getUser()).data.user?.id,
        })
        .select()
        .single()

      if (attachmentError) throw attachmentError

      // If messageId is provided, create message_attachment record
      if (messageId) {
        const { error: messageAttachmentError } = await supabase
          .from('message_attachments')
          .insert({
            message_id: messageId,
            attachment_id: attachment.id,
          })

        if (messageAttachmentError) throw messageAttachmentError
      }

      // Invalidate queries
      await queryClient.invalidateQueries({ queryKey: ['case-attachments', caseId] })
      if (messageId) {
        await queryClient.invalidateQueries({ queryKey: ['messages', caseId] })
      }

      return attachment as UploadResult
    } catch (error) {
      console.error('Error uploading file:', error)
      throw error
    } finally {
      setIsUploading(false)
      setProgress(0)
    }
  }

  const deleteFile = async (attachmentId: string, filePath: string) => {
    try {
      // Delete from storage
      const { error: storageError } = await supabase.storage
        .from('attachments')
        .remove([filePath])

      if (storageError) throw storageError

      // Delete attachment record (will cascade to message_attachments)
      const { error: dbError } = await supabase
        .from('attachments')
        .delete()
        .eq('id', attachmentId)

      if (dbError) throw dbError

      return true
    } catch (error) {
      console.error('Error deleting file:', error)
      throw error
    }
  }

  return {
    uploadFile,
    deleteFile,
    isUploading,
    progress,
  }
} 