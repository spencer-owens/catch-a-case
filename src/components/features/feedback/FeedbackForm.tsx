import * as React from 'react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { useFeedback } from '@/lib/hooks/useFeedback'
import { cn } from '@/lib/utils'
import { Star } from 'lucide-react'

interface FeedbackFormProps {
  caseId: string
  onSubmitted?: () => void
  className?: string
}

export function FeedbackForm({ caseId, onSubmitted, className }: FeedbackFormProps) {
  const [rating, setRating] = React.useState(0)
  const [hoveredRating, setHoveredRating] = React.useState(0)
  const [comments, setComments] = React.useState('')
  const { submitFeedback, isSubmitting, feedback } = useFeedback(caseId)

  // If feedback already exists, show it in read-only mode
  const existingFeedback = feedback as { rating: number; comments: string } | null

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (rating === 0) return

    await submitFeedback({ rating, comments })
    onSubmitted?.()
  }

  if (existingFeedback) {
    return (
      <div className={cn('space-y-4', className)}>
        <div className="flex items-center gap-1">
          {[1, 2, 3, 4, 5].map((value) => (
            <Star
              key={value}
              className={cn(
                'w-6 h-6',
                value <= existingFeedback.rating
                  ? 'fill-primary text-primary'
                  : 'fill-none text-muted-foreground'
              )}
            />
          ))}
        </div>
        {existingFeedback.comments && (
          <p className="text-sm text-muted-foreground">
            {existingFeedback.comments}
          </p>
        )}
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className={cn('space-y-4', className)}>
      <div
        className="flex items-center gap-1"
        onMouseLeave={() => setHoveredRating(0)}
      >
        {[1, 2, 3, 4, 5].map((value) => (
          <button
            key={value}
            type="button"
            onClick={() => setRating(value)}
            onMouseEnter={() => setHoveredRating(value)}
            className="p-1 hover:scale-110 transition-transform"
          >
            <Star
              className={cn(
                'w-6 h-6',
                value <= (hoveredRating || rating)
                  ? 'fill-primary text-primary'
                  : 'fill-none text-muted-foreground'
              )}
            />
          </button>
        ))}
      </div>
      <Textarea
        value={comments}
        onChange={(e) => setComments(e.target.value)}
        placeholder="Share your experience with us..."
        className="min-h-[100px]"
      />
      <Button type="submit" disabled={rating === 0 || isSubmitting}>
        Submit Feedback
      </Button>
    </form>
  )
} 