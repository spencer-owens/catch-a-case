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

interface Agent {
  id: string
  email: string
}

interface AssignAgentDialogProps {
  caseId: string
  currentAgent: Agent | null
  onAgentUpdate: () => void
}

export function AssignAgentDialog({
  caseId,
  currentAgent,
  onAgentUpdate,
}: AssignAgentDialogProps) {
  const [open, setOpen] = React.useState(false)

  const { data: agents } = useQuery<Agent[]>({
    queryKey: ["agents"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("users")
        .select("id, email")
        .eq("role", "agent")

      if (error) throw error
      return data
    },
  })

  const updateAgentMutation = useMutation({
    mutationFn: async (agentId: string | null) => {
      console.log('Updating agent to:', agentId)
      const { error } = await supabase
        .from("cases")
        .update({ assigned_agent_id: agentId })
        .eq("id", caseId)

      if (error) throw error
    },
    onSuccess: () => {
      toast({
        title: "Agent updated",
        description: "The case has been successfully reassigned.",
      })
      onAgentUpdate()
      setOpen(false)
    },
    onError: (error) => {
      console.error('Agent update error:', error)
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to update agent",
        variant: "destructive",
      })
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" className="w-[200px] justify-between">
          {currentAgent?.email || "Not assigned"}
        </Button>
      </DialogTrigger>
      <DialogContent className="max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Assign Agent</DialogTitle>
          <DialogDescription>
            Select an agent to assign to this case.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-2">
          <Button
            variant={!currentAgent ? "secondary" : "outline"}
            className="justify-start"
            onClick={() => {
              if (currentAgent) {
                updateAgentMutation.mutate(null)
              }
            }}
          >
            <Check
              className={cn(
                "mr-2 h-4 w-4",
                !currentAgent ? "opacity-100" : "opacity-0"
              )}
            />
            Not assigned
          </Button>
          {agents?.map((agent) => (
            <Button
              key={agent.id}
              variant={agent.id === currentAgent?.id ? "secondary" : "outline"}
              className="justify-start"
              onClick={() => {
                if (agent.id !== currentAgent?.id) {
                  updateAgentMutation.mutate(agent.id)
                }
              }}
            >
              <Check
                className={cn(
                  "mr-2 h-4 w-4",
                  agent.id === currentAgent?.id ? "opacity-100" : "opacity-0"
                )}
              />
              {agent.email}
            </Button>
          ))}
        </div>
      </DialogContent>
    </Dialog>
  )
} 