import * as React from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../../lib/context/auth-context'
import { Button } from '../ui/button'
import { cn } from '../../lib/utils'

interface MainLayoutProps {
  children: React.ReactNode
  className?: string
  showNav?: boolean
}

export function MainLayout({ children, className, showNav = true }: MainLayoutProps) {
  const { user, signOut } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  const isActive = (path: string) => location.pathname === path

  if (!showNav) {
    return (
      <div className="min-h-screen bg-background">
        <div className={cn("container mx-auto px-4 py-8", className)}>
          {children}
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="container mx-auto px-4">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center gap-8">
              <Link to="/dashboard" className="text-xl font-semibold">
                Catch a Case
              </Link>
              <nav className="hidden md:flex items-center gap-6">
                <Link
                  to="/dashboard"
                  className={cn(
                    "text-sm transition-colors hover:text-primary",
                    isActive('/dashboard') ? "text-primary font-medium" : "text-muted-foreground"
                  )}
                >
                  Dashboard
                </Link>
                {user?.user_metadata?.role === 'admin' && (
                  <Link
                    to="/admin"
                    className={cn(
                      "text-sm transition-colors hover:text-primary",
                      isActive('/admin') ? "text-primary font-medium" : "text-muted-foreground"
                    )}
                  >
                    Admin
                  </Link>
                )}
              </nav>
            </div>
            <div className="flex items-center gap-4">
              <span className="hidden md:inline text-sm text-muted-foreground">
                {user?.email}
              </span>
              <Button variant="outline" size="sm" onClick={() => signOut()}>
                Sign Out
              </Button>
            </div>
          </div>
        </div>
      </header>
      <main>
        <div className={cn("container mx-auto px-4 py-8", className)}>
          {children}
        </div>
      </main>
    </div>
  )
} 