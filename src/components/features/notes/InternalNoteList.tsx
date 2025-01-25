import * as React from 'react'
import { useInternalNotes, type InternalNote } from '@/lib/hooks/useInternalNotes'
import { useAuth } from '@/lib/hooks/useAuth'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { ScrollArea } from '@/components/ui/scroll-area'
import { cn } from '@/lib/utils'

interface InternalNoteListProps {
  caseId: string
  className?: string
}

export function InternalNoteList({ caseId, className }: InternalNoteListProps) {
  const { notes, addNote } = useInternalNotes(caseId)
  const { user } = useAuth()
  const [content, setContent] = React.useState('')
  const [isAdding, setIsAdding] = React.useState(false)
  const notesEndRef = React.useRef<HTMLDivElement>(null)

  const scrollToBottom = React.useCallback(() => {
    notesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [])

  // Scroll to bottom on new notes
  React.useEffect(() => {
    scrollToBottom()
  }, [notes, scrollToBottom])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!content.trim() || isAdding) return

    try {
      setIsAdding(true)
      await addNote(content)
      setContent('')
    } finally {
      setIsAdding(false)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSubmit(e)
    }
  }

  return (
    <div className={cn('flex flex-col h-[600px]', className)}>
      <ScrollArea className="flex-1 p-4">
        <div className="space-y-4">
          {notes.map((note) => (
            <NoteItem
              key={note.id}
              note={note}
              isOwn={note.agent_id === user?.id}
            />
          ))}
          <div ref={notesEndRef} />
        </div>
      </ScrollArea>
      <form onSubmit={handleSubmit} className="p-4 border-t">
        <div className="flex gap-2">
          <Textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Add an internal note... (Enter to send, Shift+Enter for new line)"
            className="min-h-[80px]"
          />
          <Button type="submit" disabled={isAdding || !content.trim()}>
            Add Note
          </Button>
        </div>
      </form>
    </div>
  )
}

interface NoteItemProps {
  note: InternalNote
  isOwn: boolean
}

function NoteItem({ note, isOwn }: NoteItemProps) {
  return (
    <div
      className={cn('flex', {
        'justify-end': isOwn,
      })}
    >
      <div
        className={cn(
          'rounded-lg p-3 max-w-[80%]',
          isOwn
            ? 'bg-primary text-primary-foreground'
            : 'bg-muted text-muted-foreground'
        )}
      >
        <p className="text-sm whitespace-pre-wrap break-words">
          {note.note_content}
        </p>
        <span className="text-xs opacity-70 mt-1 block">
          {new Date(note.created_at).toLocaleTimeString()}
        </span>
      </div>
    </div>
  )
} 