import { FileUploadZone } from './FileUploadZone'
import { FilePreview } from './FilePreview'
import { useMessageAttachments } from '@/lib/hooks/useAttachments'
import { Loader2 } from 'lucide-react'

interface MessageAttachmentsProps {
  messageId: string
  caseId: string
  className?: string
}

export function MessageAttachments({ messageId, caseId, className }: MessageAttachmentsProps) {
  const { data: attachments, isLoading } = useMessageAttachments(messageId)

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-4">
        <Loader2 className="w-4 h-4 animate-spin text-muted-foreground" />
      </div>
    )
  }

  return (
    <div className={className}>
      <div className="space-y-2">
        {attachments?.map((attachment) => (
          <FilePreview
            key={attachment.id}
            id={attachment.id}
            fileName={attachment.file_name}
            filePath={attachment.file_path}
            fileSize={attachment.file_size}
            fileType={attachment.file_type}
          />
        ))}
      </div>
      <FileUploadZone 
        caseId={caseId} 
        messageId={messageId} 
        className="mt-4" 
      />
    </div>
  )
} 