import * as React from 'react'
import { useMessages, type Message } from '@/lib/hooks/useMessages'
import { useAuth } from '@/lib/context/auth-context'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { ScrollArea } from '@/components/ui/scroll-area'
import { cn } from '@/lib/utils'

interface MessageListProps {
  caseId: string
  className?: string
}

export function MessageList({ caseId, className }: MessageListProps) {
  const { messages, sendMessage } = useMessages(caseId)
  const { user, isAgent } = useAuth()
  const isAdmin = user?.user_metadata?.role === 'admin'
  const [content, setContent] = React.useState('')
  const [isSending, setIsSending] = React.useState(false)
  const messagesEndRef = React.useRef<HTMLDivElement>(null)

  const scrollToBottom = React.useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [])

  // Scroll to bottom on new messages
  React.useEffect(() => {
    scrollToBottom()
  }, [messages, scrollToBottom])

  const handleSend = async (e?: React.FormEvent) => {
    e?.preventDefault()
    if (!content.trim() || isSending) return

    try {
      setIsSending(true)
      await sendMessage(content)
      setContent('')
    } finally {
      setIsSending(false)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  return (
    <div className={cn('flex flex-col h-[600px]', className)}>
      <ScrollArea className="flex-1 p-4">
        <div className="space-y-4">
          {messages.map((message) => (
            <MessageBubble
              key={message.id}
              message={message}
              isOwn={message.sender_id === user?.id}
              isAdmin={isAdmin}
            />
          ))}
          <div ref={messagesEndRef} />
        </div>
      </ScrollArea>
      <form onSubmit={handleSend} className="p-4 border-t">
        <div className="flex gap-2">
          <Textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type your message... (Enter to send, Shift+Enter for new line)"
            className="min-h-[80px]"
          />
          <Button type="submit" disabled={isSending || !content.trim()}>
            Send
          </Button>
        </div>
      </form>
    </div>
  )
}

interface MessageBubbleProps {
  message: Message
  isOwn: boolean
  isAdmin: boolean
}

function MessageBubble({ message, isOwn, isAdmin }: MessageBubbleProps) {
  // For admins, we want to show agent messages on the right with primary color
  const isAgentMessage = message.sender_id === message.case_agent_id

  // Determine message alignment and styling
  const shouldShowRight = isOwn || (isAdmin && isAgentMessage)
  const shouldUsePrimaryStyle = isOwn || (isAdmin && isAgentMessage)

  return (
    <div
      className={cn('flex', {
        'justify-end': shouldShowRight,
      })}
    >
      <div
        className={cn(
          'rounded-lg p-3 max-w-[80%]',
          shouldUsePrimaryStyle
            ? 'bg-primary text-primary-foreground'
            : 'bg-muted text-muted-foreground'
        )}
      >
        <p className="text-sm whitespace-pre-wrap break-words">
          {message.message_content}
        </p>
        <span className="text-xs opacity-70 mt-1 block">
          {new Date(message.created_at).toLocaleTimeString()}
        </span>
      </div>
    </div>
  )
} 