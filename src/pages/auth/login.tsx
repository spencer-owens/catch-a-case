import { LoginForm } from '@/components/auth/login-form'
import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { useState } from 'react'

interface PresetUser {
  label: string
  email: string
  password: string
}

const presetUsers: PresetUser[] = [
  { label: 'Client', email: 'kobeta9652@kurbieh.com', password: 'test123' },
  { label: 'Agent', email: 'agent4@law.com', password: 'test123' },
  { label: 'Admin', email: 'admin2@law.com', password: 'test123' },
]

function PresetUsers({ onSelect }: { onSelect: (user: PresetUser) => void }) {
  return (
    <div className="mt-6">
      <p className="text-center text-sm text-muted-foreground mb-2">Test accounts:</p>
      <div className="flex justify-center gap-2">
        {presetUsers.map((user) => (
          <Button
            key={user.email}
            variant="outline"
            size="sm"
            onClick={() => onSelect(user)}
          >
            {user.label}
          </Button>
        ))}
      </div>
    </div>
  )
}

export function LoginPage() {
  const [selectedUser, setSelectedUser] = useState<PresetUser | null>(null)

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <h1 className="text-4xl font-bold text-center mb-8">Catch a Case</h1>
        <LoginForm key={selectedUser?.email} defaultEmail={selectedUser?.email} defaultPassword={selectedUser?.password} />
        <p className="text-center mt-4 text-sm text-muted-foreground">
          Don't have an account?{' '}
          <Link to="/signup" className="text-primary hover:underline">
            Sign up
          </Link>
        </p>
        <PresetUsers onSelect={setSelectedUser} />
      </div>
    </div>
  )
} 