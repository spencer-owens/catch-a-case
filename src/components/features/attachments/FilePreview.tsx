import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { File, Loader2, Trash2, Download } from 'lucide-react'
import { useFileUpload } from '@/lib/hooks/useFileUpload'
import { supabase } from '@/lib/supabase'
import { formatFileSize } from '../../../lib/utils/format'

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
  const [thumbnailUrl, setThumbnailUrl] = useState<string | null>(null)
  const { deleteFile } = useFileUpload()

  // Generate signed URL for image thumbnails
  useEffect(() => {
    const loadThumbnail = async () => {
      if (!fileType.startsWith('image/')) return

      try {
        const { data } = await supabase.storage
          .from('case-attachments')
          .createSignedUrl(filePath, 3600, {
            transform: {
              width: 80,
              height: 80,
              resize: 'cover'
            }
          })
        
        if (data?.signedUrl) {
          setThumbnailUrl(data.signedUrl)
        }
      } catch (error) {
        console.error('Error generating thumbnail URL:', error)
      }
    }

    loadThumbnail()
  }, [filePath, fileType])

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
        <File className="w-10 h-10 text-muted-foreground" />
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
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Download className="h-4 w-4" />
          )}
        </Button>
        <Button
          variant="ghost"
          size="icon"
          onClick={handleDelete}
          disabled={isDownloading || isDeleting}
        >
          {isDeleting ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Trash2 className="h-4 w-4" />
          )}
        </Button>
      </div>
    </div>
  )
} 