import { FileUploadZone } from './FileUploadZone'
import { FilePreview } from './FilePreview'
import { useAttachments } from '@/lib/hooks/useAttachments'
import { Loader2 } from 'lucide-react'

interface AttachmentListProps {
  caseId: string
  className?: string
}

export function AttachmentList({ caseId, className }: AttachmentListProps) {
  const { data: attachments, isLoading } = useAttachments(caseId)

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <Loader2 className="w-6 h-6 animate-spin text-muted-foreground" />
      </div>
    )
  }

  return (
    <div className={className}>
      <FileUploadZone caseId={caseId} className="mb-4" />
      
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
        {attachments?.length === 0 && (
          <p className="text-sm text-muted-foreground text-center py-4">
            No attachments yet
          </p>
        )}
      </div>
    </div>
  )
} 