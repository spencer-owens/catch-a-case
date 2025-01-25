import { createContext, useContext, useEffect, useState, useCallback, useRef } from 'react'
import { User, Session } from '@supabase/supabase-js'
import { supabase } from '../supabase'
import { LoadingScreen } from '@/components/ui/loading-screen'
import { Button } from '@/components/ui/button'
import { getCachedRole, setCachedRole, updateUserWithRole } from '../utils/auth-helpers'

type AuthContextType = {
  user: User | null
  session: Session | null
  isAgent: boolean
  signUp: (email: string, password: string) => Promise<{ error: Error | null; requiresEmailConfirmation?: boolean }>
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
  loading: boolean
  error: Error | null
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  const initializationComplete = useRef(false)

  // Function to fetch user role from public.users
  const fetchAndUpdateUserRole = useCallback(async (currentUser: User): Promise<User> => {
    console.log('🔍 Fetching role for:', currentUser.email)
    
    // Check cache first
    const cachedRole = getCachedRole(currentUser.id)
    if (cachedRole) {
      console.log('📦 Using cached role:', cachedRole)
      return updateUserWithRole(currentUser, cachedRole)
    }

    try {
      const { data: userData, error } = await supabase
        .from('users')
        .select('role')
        .eq('id', currentUser.id)
        .single()

      if (error) throw error

      const role = userData.role
      console.log('✅ Fetched role:', role)
      
      // Cache the role
      setCachedRole(currentUser.id, role)
      
      return updateUserWithRole(currentUser, role)
    } catch (err) {
      console.error('❌ Error fetching role:', err)
      // Return user with existing metadata if we can't fetch role
      return currentUser
    }
  }, [])

  // Function to update auth state
  const updateAuthState = useCallback(async (session: Session | null) => {
    try {
      if (session?.user) {
        const userWithRole = await fetchAndUpdateUserRole(session.user)
        setSession(session)
        setUser(userWithRole)
      } else {
        setSession(null)
        setUser(null)
      }
    } catch (err) {
      console.error('Error updating auth state:', err)
      setError(err instanceof Error ? err : new Error('Failed to update auth state'))
    } finally {
      setLoading(false)
    }
  }, [fetchAndUpdateUserRole])

  useEffect(() => {
    let mounted = true
    
    // Get initial session
    const initializeAuth = async () => {
      // Skip if already initialized
      if (initializationComplete.current) return
      
      try {
        const { data: { session }, error: sessionError } = await supabase.auth.getSession()
        
        if (sessionError) throw sessionError
        if (mounted) {
          await updateAuthState(session)
          initializationComplete.current = true
        }
      } catch (err) {
        console.error('Auth initialization error:', err)
        if (mounted) {
          setError(err instanceof Error ? err : new Error('Failed to initialize auth'))
          setLoading(false)
        }
      }
    }

    initializeAuth()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      if (!mounted) return
      await updateAuthState(session)
    })

    return () => {
      mounted = false
      subscription.unsubscribe()
    }
  }, [updateAuthState])

  const signUp = async (email: string, password: string) => {
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/auth/callback`,
          data: {
            role: 'client',
          },
        },
      })
      
      if (error) {
        console.error('Signup error:', error)
        if (error.message.includes('duplicate')) {
          return { error: new Error('This email is already registered. Please sign in instead.') }
        }
        return { error }
      }

      // If we have a user but no session, email confirmation is required
      if (data.user && !data.session) {
        return { error: null, requiresEmailConfirmation: true }
      }

      return { error: null }
    } catch (err) {
      console.error('Unexpected signup error:', err)
      return { error: err instanceof Error ? err : new Error('An unexpected error occurred') }
    }
  }

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    
    if (error) {
      console.error('Login error:', error)
      if (error.message.includes('Email not confirmed')) {
        throw new Error('Please confirm your email address before signing in')
      }
      if (error.message.includes('Invalid login credentials')) {
        throw new Error('Invalid email or password')
      }
      throw error
    }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) {
      console.error('Signout error:', error)
      throw error
    }
  }

  const value = {
    user,
    session,
    isAgent: user?.user_metadata?.role === 'agent' || user?.user_metadata?.role === 'admin',
    signUp,
    signIn,
    signOut,
    loading,
    error,
  }

  console.log('🎭 Auth Provider state:', { loading, error: error?.message, user: user?.email })

  if (loading) {
    return <LoadingScreen />
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-4">
        <div className="text-center space-y-4">
          <p className="text-destructive">Failed to initialize authentication</p>
          <Button 
            variant="outline" 
            onClick={() => window.location.reload()}
          >
            Retry
          </Button>
        </div>
      </div>
    )
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
} 