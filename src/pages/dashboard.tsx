import { useNavigate } from 'react-router-dom'
import { useAuth } from '../lib/context/auth-context'
import { Button } from '../components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card'
import { CaseList } from '../components/cases/case-list'
import { PageTransition } from '../components/ui/page-transition'

// Client-specific dashboard content
function ClientDashboardContent() {
  const navigate = useNavigate()
  const { user } = useAuth()

  return (
    <div className="space-y-4">
      <PageTransition>
        <Card>
          <CardHeader>
            <CardTitle>My Cases</CardTitle>
            <CardDescription>
              View and manage your active cases
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button 
              className="w-full mb-6"
              onClick={() => navigate('/cases/create')}
            >
              Create New Case
            </Button>
            <CaseList userId={user?.id!} role="client" />
          </CardContent>
        </Card>
      </PageTransition>

      <PageTransition className="delay-100">
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>
              Common tasks and updates
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <Button variant="outline" className="w-full">
              Message Your Agent
            </Button>
            <Button variant="outline" className="w-full">
              Upload Documents
            </Button>
          </CardContent>
        </Card>
      </PageTransition>
    </div>
  )
}

// Agent/Admin-specific dashboard content
function AgentDashboardContent() {
  const { user } = useAuth()
  const role = user?.user_metadata?.role

  return (
    <div className="space-y-4">
      <PageTransition>
        <Card>
          <CardHeader>
            <CardTitle>Case Queue</CardTitle>
            <CardDescription>
              Manage your assigned cases
            </CardDescription>
          </CardHeader>
          <CardContent>
            <CaseList userId={user?.id!} role={role} />
          </CardContent>
        </Card>
      </PageTransition>

      <PageTransition className="delay-100">
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
            <CardDescription>
              Latest updates from your cases
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-sm text-muted-foreground">
              No recent activity to display.
            </div>
          </CardContent>
        </Card>
      </PageTransition>
    </div>
  )
}

export function DashboardPage() {
  const { user } = useAuth()
  const isAgent = user?.user_metadata?.role === 'agent' || user?.user_metadata?.role === 'admin'

  return (
    <div>
      <PageTransition>
        <div className="mb-8">
          <h1 className="text-4xl font-bold">Dashboard</h1>
          <p className="text-muted-foreground mt-1">
            Welcome back, {user?.email}
          </p>
        </div>
      </PageTransition>

      {isAgent ? <AgentDashboardContent /> : <ClientDashboardContent />}
    </div>
  )
} 