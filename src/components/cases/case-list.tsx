import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { format } from 'date-fns'
import { supabase } from '@/lib/supabase'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'

interface Case {
  id: string
  title: string
  description: string
  created_at: string
  status: {
    id: string
    status_name: string
  }
  assigned_agent: {
    id: string
    email: string
  } | null
}

interface CaseListProps {
  userId: string
  role: 'client' | 'agent' | 'admin'
}

function CaseStatusBadge({ status }: { status: string }) {
  const variantMap: Record<string, 'default' | 'secondary' | 'destructive'> = {
    'Intake': 'default',
    'Pre-litigation': 'secondary',
    'Litigation': 'destructive',
    'Settlement': 'secondary',
    'Closed': 'default',
  }

  return (
    <Badge variant={variantMap[status] || 'default'}>
      {status}
    </Badge>
  )
}

function CaseSkeleton() {
  return (
    <Card>
      <CardHeader>
        <Skeleton className="h-6 w-2/3" />
        <Skeleton className="h-4 w-1/3" />
      </CardHeader>
      <CardContent>
        <Skeleton className="h-4 w-full mb-2" />
        <Skeleton className="h-4 w-3/4" />
      </CardContent>
    </Card>
  )
}

export function CaseList({ userId, role }: CaseListProps) {
  const navigate = useNavigate()

  const { data: cases, isLoading } = useQuery({
    queryKey: ['cases', userId, role],
    queryFn: async () => {
      const query = supabase
        .from('cases')
        .select(`
          id,
          title,
          description,
          created_at,
          status:status_id(id, status_name),
          assigned_agent:assigned_agent_id(id, email)
        `)

      // Apply role-based filters
      if (role === 'client') {
        query.eq('client_id', userId)
      } else if (role === 'agent') {
        query.eq('assigned_agent_id', userId)
      }
      // Admins can see all cases

      const { data, error } = await query

      if (error) throw error
      return data?.map(item => ({
        ...item,
        status: Array.isArray(item.status) ? item.status[0] : item.status,
        assigned_agent: Array.isArray(item.assigned_agent) ? item.assigned_agent[0] : item.assigned_agent
      })) as Case[]
    },
  })

  if (isLoading) {
    return (
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {[...Array(6)].map((_, i) => (
          <CaseSkeleton key={i} />
        ))}
      </div>
    )
  }

  if (!cases?.length) {
    return (
      <Card>
        <CardContent className="py-8 text-center">
          <p className="text-muted-foreground">
            No cases found. {role === 'client' && 'Create one to get started.'}
          </p>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {cases.map((case_) => (
        <Card key={case_.id} className="hover:shadow-lg transition-shadow">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg">{case_.title}</CardTitle>
              <CaseStatusBadge status={case_.status.status_name} />
            </div>
            <CardDescription>
              Created {format(new Date(case_.created_at), 'MMM d, yyyy')}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground line-clamp-2 mb-4">
              {case_.description}
            </p>
            {case_.assigned_agent && (
              <p className="text-sm text-muted-foreground mb-4">
                Assigned to: {case_.assigned_agent.email}
              </p>
            )}
            <div className="flex justify-end">
              <Button
                variant="outline"
                size="sm"
                onClick={() => navigate(`/cases/${case_.id}`)}
              >
                View Details
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
} 