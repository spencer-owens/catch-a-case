import * as React from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { format } from 'date-fns'
import { useAuth } from '@/lib/context/auth-context'
import { supabase } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { CaseStatusBadge } from "@/components/cases/case-status-badge"
import { UpdateStatusDialog } from "@/components/cases/update-status-dialog"
import { AssignAgentDialog } from "@/components/cases/assign-agent-dialog"
import { MessageList } from "@/components/features/messages/MessageList"
import { InternalNoteList } from "@/components/features/notes/InternalNoteList"
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible"
import { ChevronDown, ChevronUp } from 'lucide-react'
import { useMessages } from '@/lib/hooks/useMessages'
import { useInternalNotes } from '@/lib/hooks/useInternalNotes'
import { cn } from '@/lib/utils'

interface CaseDetails {
  id: string
  title: string
  description: string
  created_at: string
  client: {
    id: string
    email: string
  }
  assigned_agent: {
    id: string
    email: string
  } | null
  status: {
    id: string
    status_name: string
  }
}

function CaseSkeleton() {
  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <Skeleton className="h-8 w-[250px]" />
        <Skeleton className="h-4 w-[200px]" />
      </div>
      <div className="space-y-2">
        <Skeleton className="h-4 w-[300px]" />
        <Skeleton className="h-4 w-[250px]" />
      </div>
    </div>
  )
}

function MessagePreview({ message, isAdmin }: { message: any, isAdmin: boolean }) {
  const { user } = useAuth()
  const isOwn = message.sender_id === user?.id
  const isAgentMessage = message.sender_id === message.case_agent_id
  const shouldUsePrimaryStyle = isOwn || (isAdmin && isAgentMessage)

  return (
    <div className="mt-4 mb-2">
      <div
        className={cn(
          'rounded-lg p-3 w-full',
          shouldUsePrimaryStyle
            ? 'bg-primary text-primary-foreground'
            : 'bg-muted text-muted-foreground'
        )}
      >
        <p className="text-sm whitespace-pre-wrap break-words line-clamp-2">
          {message.message_content}
        </p>
        <span className="text-xs opacity-70 mt-1 block">
          {new Date(message.created_at).toLocaleTimeString()}
        </span>
      </div>
    </div>
  )
}

function NotePreview({ note }: { note: any }) {
  const { user } = useAuth()
  const isOwn = note.agent_id === user?.id

  return (
    <div className="mt-4 mb-2">
      <div
        className={cn(
          'rounded-lg p-3 w-full',
          isOwn
            ? 'bg-primary text-primary-foreground'
            : 'bg-muted text-muted-foreground'
        )}
      >
        <p className="text-sm whitespace-pre-wrap break-words line-clamp-2">
          {note.note_content}
        </p>
        <span className="text-xs opacity-70 mt-1 block">
          {new Date(note.created_at).toLocaleTimeString()}
        </span>
      </div>
    </div>
  )
}

export function CaseDetailsPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { user, isAgent } = useAuth()
  const isAdmin = user?.user_metadata?.role === 'admin'
  const [isMessagesOpen, setIsMessagesOpen] = React.useState(true)
  const [isNotesOpen, setIsNotesOpen] = React.useState(false)
  const { messages } = useMessages(id!)
  const { notes } = useInternalNotes(id!)

  // Get most recent message and note
  const latestMessage = messages?.[messages.length - 1]
  const latestNote = notes?.[notes.length - 1]

  const { data, isLoading, error, refetch } = useQuery<CaseDetails>({
    queryKey: ["case", id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('cases')
        .select(`
          id,
          title,
          description,
          created_at,
          client:client_id(id, email),
          assigned_agent:assigned_agent_id(id, email),
          status:status_id(id, status_name)
        `)
        .eq('id', id)
        .single()

      if (error) throw error

      // Transform the nested arrays into objects
      if (!data) throw new Error('Case not found')

      // Handle the nested objects correctly
      const transformedData = {
        ...data,
        // If client/status are objects, use them directly; if arrays, take first element
        client: Array.isArray(data.client) ? data.client[0] : data.client,
        assigned_agent: Array.isArray(data.assigned_agent) 
          ? data.assigned_agent[0] 
          : data.assigned_agent || null,
        status: Array.isArray(data.status) ? data.status[0] : data.status,
      }

      // Validate only the required fields
      if (!transformedData.id || !transformedData.title) {
        console.error('Missing basic fields:', transformedData)
        throw new Error('Case data is missing basic fields')
      }

      if (!transformedData.client?.id || !transformedData.client?.email) {
        console.error('Missing client data:', transformedData.client)
        throw new Error('Case is missing client information')
      }

      if (!transformedData.status?.id || !transformedData.status?.status_name) {
        console.error('Missing status data:', transformedData.status)
        throw new Error('Case is missing status information')
      }

      return transformedData as CaseDetails
    },
    retry: false, // Don't retry on error
  })

  if (isLoading) {
    return (
      <div className="container py-6">
        <CaseSkeleton />
      </div>
    )
  }

  if (error || !data) {
    return (
      <div className="container py-6">
        <Card>
          <CardContent className="py-8 text-center">
            <p className="text-muted-foreground">
              {error instanceof Error 
                ? error.message 
                : 'Error loading case details. The case may not exist or you may not have permission to view it.'}
            </p>
            <Button
              variant="outline"
              className="mt-4"
              onClick={() => navigate('/dashboard')}
            >
              Return to Dashboard
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="container py-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold">{data.title}</h1>
        <p className="text-muted-foreground">
          Created on {format(new Date(data.created_at), "PPP")}
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Case Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <div className="font-medium">Description</div>
              <p className="text-muted-foreground">{data.description}</p>
            </div>
            <div>
              <div className="font-medium">Client</div>
              <p className="text-muted-foreground">{data.client.email}</p>
            </div>
            <div>
              <div className="font-medium">Status</div>
              <div className="flex items-center gap-4">
                {isAgent ? (
                  <UpdateStatusDialog
                    caseId={data.id}
                    currentStatus={data.status}
                    onStatusUpdate={refetch}
                  />
                ) : (
                  <CaseStatusBadge status={data.status.status_name} />
                )}
              </div>
            </div>
            <div>
              <div className="font-medium">Assigned Agent</div>
              <div className="flex items-center gap-4">
                {isAgent ? (
                  <AssignAgentDialog
                    caseId={data.id}
                    currentAgent={data.assigned_agent}
                    onAgentUpdate={refetch}
                  />
                ) : (
                  <p className="text-muted-foreground">
                    {data.assigned_agent?.email || "Not assigned"}
                  </p>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        <div className="space-y-6">
          <Card>
            <Collapsible open={isMessagesOpen} onOpenChange={setIsMessagesOpen}>
              <CardHeader className="pb-0">
                <div className="flex items-center justify-between">
                  <CardTitle>Messages</CardTitle>
                  <CollapsibleTrigger asChild>
                    <Button variant="ghost" size="sm">
                      {isMessagesOpen ? (
                        <ChevronUp className="h-4 w-4" />
                      ) : (
                        <ChevronDown className="h-4 w-4" />
                      )}
                    </Button>
                  </CollapsibleTrigger>
                </div>
                {!isMessagesOpen && latestMessage && (
                  <div className="mt-2">
                    <MessagePreview message={latestMessage} isAdmin={isAdmin} />
                  </div>
                )}
              </CardHeader>
              <CollapsibleContent>
                <CardContent className="p-0">
                  <MessageList caseId={data.id} />
                </CardContent>
              </CollapsibleContent>
            </Collapsible>
          </Card>

          {isAgent && (
            <Card>
              <Collapsible open={isNotesOpen} onOpenChange={setIsNotesOpen}>
                <CardHeader className="pb-0">
                  <div className="flex items-center justify-between">
                    <div>
                      <CardTitle>Internal Notes</CardTitle>
                      <CardDescription>
                        Notes visible only to agents and admins
                      </CardDescription>
                    </div>
                    <CollapsibleTrigger asChild>
                      <Button variant="ghost" size="sm">
                        {isNotesOpen ? (
                          <ChevronUp className="h-4 w-4" />
                        ) : (
                          <ChevronDown className="h-4 w-4" />
                        )}
                      </Button>
                    </CollapsibleTrigger>
                  </div>
                  {!isNotesOpen && latestNote && (
                    <div className="mt-2">
                      <NotePreview note={latestNote} />
                    </div>
                  )}
                </CardHeader>
                <CollapsibleContent>
                  <CardContent className="p-0">
                    <InternalNoteList caseId={data.id} />
                  </CardContent>
                </CollapsibleContent>
              </Collapsible>
            </Card>
          )}
        </div>
      </div>
    </div>
  )
} 