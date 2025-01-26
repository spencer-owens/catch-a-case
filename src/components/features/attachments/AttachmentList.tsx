import { FileUploadZone } from './FileUploadZone'
import { FilePreview } from './FilePreview'
import { useAttachments } from '@/lib/hooks/useAttachments'
import { useAuth } from '@/lib/context/auth-context'
import { Loader2, ChevronDown } from 'lucide-react'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'

interface AttachmentListProps {
  caseId: string
  className?: string
}

export function AttachmentList({ caseId, className }: AttachmentListProps) {
  const { data: attachments, isLoading } = useAttachments(caseId)
  const { user } = useAuth()
  const isClient = user?.user_metadata?.role === 'client'

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <Loader2 className="w-6 h-6 animate-spin text-muted-foreground" />
      </div>
    )
  }

  const clientFiles = attachments?.filter(
    (attachment) => attachment.uploader?.role === 'client'
  ) || []

  const staffFiles = attachments?.filter(
    (attachment) => attachment.uploader?.role !== 'client'
  ) || []

  return (
    <div className={className}>
      <FileUploadZone caseId={caseId} className="mb-4" />
      
      <div className="space-y-4">
        <Collapsible defaultOpen>
          <CollapsibleTrigger className="flex items-center justify-between w-full p-2 text-sm font-medium hover:bg-accent rounded-lg">
            {isClient ? "Files You've Uploaded" : "Uploaded by Client"}
            <ChevronDown className="h-4 w-4" />
          </CollapsibleTrigger>
          <CollapsibleContent className="pt-2 space-y-2">
            {clientFiles.map((attachment) => (
              <FilePreview
                key={attachment.id}
                id={attachment.id}
                fileName={attachment.file_name}
                filePath={attachment.file_path}
                fileSize={attachment.file_size}
                fileType={attachment.file_type}
              />
            ))}
            {clientFiles.length === 0 && (
              <p className="text-sm text-muted-foreground text-center py-4">
                {isClient 
                  ? "You haven't uploaded any files yet"
                  : "No files uploaded by client yet"
                }
              </p>
            )}
          </CollapsibleContent>
        </Collapsible>

        <Collapsible defaultOpen>
          <CollapsibleTrigger className="flex items-center justify-between w-full p-2 text-sm font-medium hover:bg-accent rounded-lg">
            {isClient ? "Files You've Received" : "Sent to Client"}
            <ChevronDown className="h-4 w-4" />
          </CollapsibleTrigger>
          <CollapsibleContent className="pt-2 space-y-2">
            {staffFiles.map((attachment) => (
              <FilePreview
                key={attachment.id}
                id={attachment.id}
                fileName={attachment.file_name}
                filePath={attachment.file_path}
                fileSize={attachment.file_size}
                fileType={attachment.file_type}
              />
            ))}
            {staffFiles.length === 0 && (
              <p className="text-sm text-muted-foreground text-center py-4">
                {isClient
                  ? 'No files have been shared with you yet'
                  : 'No files have been sent to client yet'
                }
              </p>
            )}
          </CollapsibleContent>
        </Collapsible>
      </div>
    </div>
  )
} 