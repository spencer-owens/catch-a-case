import { User } from '@supabase/supabase-js'

const CACHED_ROLE_KEY = 'cached_user_role'

interface CachedRole {
  userId: string
  role: string
  timestamp: number
}

export function getCachedRole(userId: string): string | null {
  try {
    const cached = localStorage.getItem(CACHED_ROLE_KEY)
    if (!cached) return null

    const parsedCache: CachedRole = JSON.parse(cached)
    
    // Cache expires after 1 hour
    if (
      parsedCache.userId === userId && 
      Date.now() - parsedCache.timestamp < 1000 * 60 * 60
    ) {
      return parsedCache.role
    }
    
    return null
  } catch (err) {
    console.warn('Failed to read cached role:', err)
    return null
  }
}

export function setCachedRole(userId: string, role: string) {
  try {
    const cacheData: CachedRole = {
      userId,
      role,
      timestamp: Date.now()
    }
    localStorage.setItem(CACHED_ROLE_KEY, JSON.stringify(cacheData))
  } catch (err) {
    console.warn('Failed to cache role:', err)
  }
}

export function updateUserWithRole(user: User, role: string): User {
  return {
    ...user,
    user_metadata: {
      ...user.user_metadata,
      role
    }
  }
} 