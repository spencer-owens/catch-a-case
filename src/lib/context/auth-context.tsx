import { createContext, useContext, useEffect, useState } from 'react'
import { User, Session } from '@supabase/supabase-js'
import { supabase } from '../supabase'

type AuthContextType = {
  user: User | null
  session: Session | null
  signUp: (email: string, password: string) => Promise<{ error: Error | null; requiresEmailConfirmation?: boolean }>
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
  loading: boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  // Function to fetch user role from public.users
  const fetchAndUpdateUserRole = async (currentUser: User) => {
    try {
      const { data: userData, error } = await supabase
        .from('users')
        .select('role')
        .eq('id', currentUser.id)
        .single()

      if (error) {
        console.error('Error fetching user role:', error)
        return currentUser
      }

      // Update user metadata with the role from public.users
      return {
        ...currentUser,
        user_metadata: {
          ...currentUser.user_metadata,
          role: userData.role
        }
      }
    } catch (err) {
      console.error('Unexpected error fetching user role:', err)
      return currentUser
    }
  }

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      setSession(session)
      if (session?.user) {
        const userWithRole = await fetchAndUpdateUserRole(session.user)
        setUser(userWithRole)
      } else {
        setUser(null)
      }
      setLoading(false)
    })

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (_event, session) => {
      setSession(session)
      if (session?.user) {
        const userWithRole = await fetchAndUpdateUserRole(session.user)
        setUser(userWithRole)
      } else {
        setUser(null)
      }
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

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

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        signUp,
        signIn,
        signOut,
        loading,
      }}
    >
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