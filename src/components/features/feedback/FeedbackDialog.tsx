import * as React from 'react'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { FeedbackForm } from './FeedbackForm'

interface FeedbackDialogProps {
  caseId: string
  isOpen: boolean
  onOpenChange: (open: boolean) => void
}

export function FeedbackDialog({
  caseId,
  isOpen,
  onOpenChange,
}: FeedbackDialogProps) {
  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Share Your Feedback</DialogTitle>
          <DialogDescription>
            Your feedback helps us improve our service. Please take a moment to rate your experience.
          </DialogDescription>
        </DialogHeader>
        <FeedbackForm
          caseId={caseId}
          onSubmitted={() => onOpenChange(false)}
          className="pt-4"
        />
      </DialogContent>
    </Dialog>
  )
} 