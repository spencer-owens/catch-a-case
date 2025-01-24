import * as React from "react"
import { useQuery, useMutation } from "@tanstack/react-query"
import { Check } from "lucide-react"

import { cn } from "@/lib/utils"
import { supabase } from "@/lib/supabase"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogTrigger,
} from "@/components/ui/dialog"
import { toast } from "@/components/ui/use-toast"

interface Status {
  id: string
  status_name: string
}

interface UpdateStatusDialogProps {
  caseId: string
  currentStatus: Status
  onStatusUpdate: () => void
}

export function UpdateStatusDialog({
  caseId,
  currentStatus,
  onStatusUpdate,
}: UpdateStatusDialogProps) {
  const [open, setOpen] = React.useState(false)

  const { data: statuses } = useQuery<Status[]>({
    queryKey: ["statuses"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("statuses")
        .select("id, status_name")
        .order("order_index")

      if (error) throw error
      return data
    },
  })

  const updateStatusMutation = useMutation({
    mutationFn: async (statusId: string) => {
      console.log('Updating status to:', statusId)
      const { error } = await supabase
        .from("cases")
        .update({ status_id: statusId })
        .eq("id", caseId)

      if (error) throw error
    },
    onSuccess: () => {
      toast({
        title: "Status updated",
        description: "The case status has been successfully updated.",
      })
      onStatusUpdate()
      setOpen(false)
    },
    onError: (error) => {
      console.error('Status update error:', error)
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to update status",
        variant: "destructive",
      })
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" className="w-[200px] justify-between">
          {currentStatus.status_name}
        </Button>
      </DialogTrigger>
      <DialogContent className="max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Update Status</DialogTitle>
          <DialogDescription>
            Select a new status for this case.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-2">
          {statuses?.map((status) => (
            <Button
              key={status.id}
              variant={status.id === currentStatus.id ? "secondary" : "outline"}
              className="justify-start"
              onClick={() => {
                if (status.id !== currentStatus.id) {
                  updateStatusMutation.mutate(status.id)
                }
              }}
            >
              <Check
                className={cn(
                  "mr-2 h-4 w-4",
                  status.id === currentStatus.id ? "opacity-100" : "opacity-0"
                )}
              />
              {status.status_name}
            </Button>
          ))}
        </div>
      </DialogContent>
    </Dialog>
  )
} 