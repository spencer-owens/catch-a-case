import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { MainLayout } from '../main-layout'
import { AuthProvider } from '../../../lib/context/auth-context'
import { describe, it, expect, vi } from 'vitest'

// Mock the auth context
vi.mock('../../../lib/context/auth-context', () => ({
  useAuth: () => ({
    user: {
      email: 'test@example.com',
      user_metadata: { role: 'client' }
    },
    signOut: vi.fn()
  }),
  AuthProvider: ({ children }: { children: React.ReactNode }) => <>{children}</>
}))

describe('MainLayout', () => {
  it('renders children content', () => {
    render(
      <BrowserRouter>
        <AuthProvider>
          <MainLayout>
            <div>Test Content</div>
          </MainLayout>
        </AuthProvider>
      </BrowserRouter>
    )

    expect(screen.getByText('Test Content')).toBeInTheDocument()
  })

  it('shows navigation when showNav is true', () => {
    render(
      <BrowserRouter>
        <AuthProvider>
          <MainLayout showNav={true}>
            <div>Test Content</div>
          </MainLayout>
        </AuthProvider>
      </BrowserRouter>
    )

    expect(screen.getByText('Dashboard')).toBeInTheDocument()
    expect(screen.getByText('test@example.com')).toBeInTheDocument()
  })

  it('hides navigation when showNav is false', () => {
    render(
      <BrowserRouter>
        <AuthProvider>
          <MainLayout showNav={false}>
            <div>Test Content</div>
          </MainLayout>
        </AuthProvider>
      </BrowserRouter>
    )

    expect(screen.queryByText('Dashboard')).not.toBeInTheDocument()
    expect(screen.queryByText('test@example.com')).not.toBeInTheDocument()
  })
}) 