import { Navigate, useLocation } from 'react-router-dom'
import { useAuth } from '@/lib/context/auth-context'

type ProtectedRouteProps = {
  children: React.ReactNode
  allowedRoles?: string[]
}

export function ProtectedRoute({ children, allowedRoles = [] }: ProtectedRouteProps) {
  const { user, loading } = useAuth()
  const location = useLocation()

  // Show nothing while checking auth
  if (loading) {
    return null
  }

  // Not logged in - redirect to login
  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  // Check role-based access if roles are specified
  if (allowedRoles.length > 0) {
    const userRole = user.user_metadata.role as string
    if (!userRole || !allowedRoles.includes(userRole)) {
      // User's role is not allowed - redirect to dashboard
      return <Navigate to="/dashboard" replace />
    }
  }

  // Authorized - render children
  return <>{children}</>
} 