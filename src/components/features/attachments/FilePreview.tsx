import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { FileIcon, Loader2, Trash2, Download } from 'lucide-react'
import { useFileUpload } from '@/lib/hooks/useFileUpload'
import { supabase } from '@/lib/supabase'
import { formatFileSize } from '@/lib/utils/format'

interface FilePreviewProps {
  id: string
  fileName: string
  filePath: string
  fileSize: number
  fileType: string
  onDelete?: () => void
  className?: string
}

export function FilePreview({
  id,
  fileName,
  filePath,
  fileSize,
  fileType,
  onDelete,
  className,
}: FilePreviewProps) {
  const [isDeleting, setIsDeleting] = useState(false)
  const [isDownloading, setIsDownloading] = useState(false)
  const { deleteFile } = useFileUpload()

  const handleDelete = async () => {
    try {
      setIsDeleting(true)
      await deleteFile(id, filePath)
      onDelete?.()
    } catch (error) {
      console.error('Error deleting file:', error)
    } finally {
      setIsDeleting(false)
    }
  }

  const handleDownload = async () => {
    try {
      setIsDownloading(true)
      const { data, error } = await supabase.storage
        .from('case-attachments')
        .download(filePath)

      if (error) throw error

      // Create a download link
      const url = URL.createObjectURL(data)
      const link = document.createElement('a')
      link.href = url
      link.download = fileName
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Error downloading file:', error)
    } finally {
      setIsDownloading(false)
    }
  }

  const isImage = fileType.startsWith('image/')
  const thumbnailUrl = isImage 
    ? supabase.storage
        .from('case-attachments')
        .getPublicUrl(filePath)
        .data.publicUrl
    : null

  return (
    <div
      className={cn(
        'group relative flex items-center gap-3 p-3 rounded-lg border bg-card hover:bg-accent/50 transition-colors',
        className
      )}
    >
      {isImage && thumbnailUrl ? (
        <div className="w-10 h-10 rounded overflow-hidden bg-muted">
          <img
            src={thumbnailUrl}
            alt={fileName}
            className="w-full h-full object-cover"
          />
        </div>
      ) : (
        <FileIcon className="w-10 h-10 text-muted-foreground" />
      )}

      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium truncate">{fileName}</p>
        <p className="text-xs text-muted-foreground">{formatFileSize(fileSize)}</p>
      </div>

      <div className="flex items-center gap-2">
        <Button
          variant="ghost"
          size="icon"
          onClick={handleDownload}
          disabled={isDownloading || isDeleting}
        >
          {isDownloading ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : (
            <Download className="w-4 h-4" />
          )}
        </Button>
        <Button
          variant="ghost"
          size="icon"
          onClick={handleDelete}
          disabled={isDownloading || isDeleting}
          className="text-destructive hover:text-destructive"
        >
          {isDeleting ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : (
            <Trash2 className="w-4 h-4" />
          )}
        </Button>
      </div>
    </div>
  )
} 