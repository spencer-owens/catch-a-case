import { useNavigate } from 'react-router-dom'
import { useAuth } from '@/lib/context/auth-context'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { CaseList } from '@/components/cases/case-list'

// Client-specific dashboard content
function ClientDashboardContent() {
  const navigate = useNavigate()
  const { user } = useAuth()

  return (
    <div className="space-y-4">
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
    </div>
  )
}

// Agent/Admin-specific dashboard content
function AgentDashboardContent() {
  const { user } = useAuth()
  const role = user?.user_metadata?.role

  return (
    <div className="space-y-4">
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
    </div>
  )
}

export function DashboardPage() {
  const { user, signOut } = useAuth()
  const isAgent = user?.user_metadata?.role === 'agent' || user?.user_metadata?.role === 'admin'

  return (
    <div className="min-h-screen bg-background p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-4xl font-bold">Dashboard</h1>
            <p className="text-muted-foreground">
              Welcome back, {user?.email}
            </p>
          </div>
          <Button variant="outline" onClick={signOut}>
            Sign Out
          </Button>
        </div>

        {isAgent ? <AgentDashboardContent /> : <ClientDashboardContent />}
      </div>
    </div>
  )
} 