import * as React from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { format } from 'date-fns'
import { useAuth } from '@/lib/context/auth-context'
import { supabase } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { CaseStatusBadge } from "@/components/cases/case-status-badge"
import { UpdateStatusDialog } from "@/components/cases/update-status-dialog"
import { AssignAgentDialog } from "@/components/cases/assign-agent-dialog"
import { MessageList } from "@/components/features/messages/MessageList"
import { InternalNoteList } from "@/components/features/notes/InternalNoteList"
import { AttachmentList } from "@/components/features/attachments/AttachmentList"
import { FeedbackDialog } from "@/components/features/feedback/FeedbackDialog"
import { FeedbackForm } from "@/components/features/feedback/FeedbackForm"

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

export function CaseDetailsPage() {
  const { id } = useParams()
  const { user } = useAuth()
  const navigate = useNavigate()
  const [showFeedbackDialog, setShowFeedbackDialog] = React.useState(false)
  
  const { data: caseDetails, isLoading, refetch } = useQuery<CaseDetails>({
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

  // Show feedback dialog when case is closed
  React.useEffect(() => {
    if (!caseDetails) return
    if (caseDetails.status.status_name === 'Closed' && !caseDetails.assigned_agent) {
      setShowFeedbackDialog(true)
    }
  }, [caseDetails])

  if (isLoading) {
    return (
      <div className="container py-6">
        <CaseSkeleton />
      </div>
    )
  }

  if (!caseDetails) {
    return (
      <div className="container py-6">
        <Card>
          <CardContent className="py-8 text-center">
            <p className="text-muted-foreground">
              Error loading case details. The case may not exist or you may not have permission to view it.
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

  const isClient = user?.user_metadata?.role === 'client'
  const isAgent = user?.user_metadata?.role === 'agent' || user?.user_metadata?.role === 'admin'
  const isClosed = caseDetails.status.status_name === 'Closed'

  return (
    <div className="container py-6 min-h-[calc(100vh-4rem)]">
      <div className="mb-6">
        <h1 className="text-2xl font-bold">{caseDetails.title}</h1>
        <p className="text-muted-foreground">
          Created on {format(new Date(caseDetails.created_at), "PPP")}
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 h-[calc(100vh-12rem)]">
        {/* Left Panel - Case Information */}
        <div className="lg:col-span-5 space-y-6 overflow-y-auto">
          <Card>
            <CardHeader>
              <CardTitle>Case Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="font-medium">Description</div>
                <p className="text-muted-foreground">{caseDetails.description}</p>
              </div>
              <div>
                <div className="font-medium">Client</div>
                <p className="text-muted-foreground">{caseDetails.client.email}</p>
              </div>
              <div>
                <div className="font-medium">Status</div>
                <div className="flex items-center gap-4">
                  {isAgent ? (
                    <UpdateStatusDialog
                      caseId={caseDetails.id}
                      currentStatus={caseDetails.status}
                      onStatusUpdate={refetch}
                    />
                  ) : (
                    <CaseStatusBadge status={caseDetails.status.status_name} />
                  )}
                </div>
              </div>
              <div>
                <div className="font-medium">Assigned Agent</div>
                <div className="flex items-center gap-4">
                  {isAgent ? (
                    <AssignAgentDialog
                      caseId={caseDetails.id}
                      currentAgent={caseDetails.assigned_agent}
                      onAgentUpdate={refetch}
                    />
                  ) : (
                    <p className="text-muted-foreground">
                      {caseDetails.assigned_agent?.email || 'No agent assigned'}
                    </p>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Files & Attachments</CardTitle>
              <CardDescription>
                Upload and manage case-related documents
              </CardDescription>
            </CardHeader>
            <CardContent>
              <AttachmentList caseId={caseDetails.id} />
            </CardContent>
          </Card>

          {isClient && isClosed && (
            <Card>
              <CardHeader>
                <CardTitle>Feedback</CardTitle>
                <CardDescription>
                  Share your experience with our service
                </CardDescription>
              </CardHeader>
              <CardContent>
                <FeedbackForm caseId={caseDetails.id} />
              </CardContent>
            </Card>
          )}
        </div>

        {/* Right Panel - Communication */}
        <div className="lg:col-span-7 flex flex-col h-full">
          <Card className="flex-1 flex flex-col overflow-hidden">
            <CardHeader className="flex-shrink-0 pb-0">
              <Tabs defaultValue="messages" className="w-full">
                <TabsList className="w-full">
                  <TabsTrigger value="messages" className="flex-1">Messages</TabsTrigger>
                  {isAgent && (
                    <TabsTrigger value="notes" className="flex-1">Internal Notes</TabsTrigger>
                  )}
                </TabsList>
                <TabsContent value="messages" className="flex-1 overflow-hidden">
                  <MessageList caseId={caseDetails.id} />
                </TabsContent>
                {isAgent && (
                  <TabsContent value="notes" className="flex-1 overflow-hidden">
                    <InternalNoteList caseId={caseDetails.id} />
                  </TabsContent>
                )}
              </Tabs>
            </CardHeader>
          </Card>
        </div>
      </div>

      <FeedbackDialog
        caseId={caseDetails.id}
        isOpen={showFeedbackDialog}
        onOpenChange={setShowFeedbackDialog}
      />
    </div>
  )
} 