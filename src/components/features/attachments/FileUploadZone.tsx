import { useCallback, useState } from 'react'
import { useDropzone } from 'react-dropzone'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { Loader2, Upload } from 'lucide-react'
import { useFileUpload } from '@/lib/hooks/useFileUpload'

interface FileUploadZoneProps {
  caseId: string
  messageId?: string
  onUploadComplete?: () => void
  className?: string
}

export function FileUploadZone({ 
  caseId, 
  messageId, 
  onUploadComplete,
  className 
}: FileUploadZoneProps) {
  const [isDragging, setIsDragging] = useState(false)
  const { uploadFile, isUploading, progress } = useFileUpload()

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    try {
      for (const file of acceptedFiles) {
        await uploadFile(file, { caseId, messageId })
      }
      onUploadComplete?.()
    } catch (error) {
      console.error('Error uploading files:', error)
    }
  }, [caseId, messageId, uploadFile, onUploadComplete])

  const { getRootProps, getInputProps, isDragActive, open } = useDropzone({
    onDrop,
    multiple: true,
    onDragEnter: () => setIsDragging(true),
    onDragLeave: () => setIsDragging(false),
    noClick: true, // Disable click on the root element
  })

  return (
    <div
      {...getRootProps()}
      className={cn(
        'relative flex flex-col items-center justify-center w-full p-6 border-2 border-dashed rounded-lg transition-colors',
        isDragging || isDragActive
          ? 'border-primary bg-primary/5'
          : 'border-muted-foreground/25 hover:border-primary/50',
        className
      )}
    >
      <input {...getInputProps()} />
      
      {isUploading ? (
        <div className="flex flex-col items-center gap-2">
          <Loader2 className="w-6 h-6 animate-spin text-primary" />
          <p className="text-sm text-muted-foreground">
            Uploading... {Math.round(progress)}%
          </p>
        </div>
      ) : (
        <>
          <Upload className="w-8 h-8 mb-2 text-muted-foreground" />
          <p className="mb-1 text-sm text-muted-foreground">
            {isDragging || isDragActive
              ? "Drop files here..."
              : "Drag and drop files here, or click to select"}
          </p>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={open}
          >
            Choose Files
          </Button>
        </>
      )}
    </div>
  )
} 