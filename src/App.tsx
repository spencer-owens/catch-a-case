import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from '@/lib/context/auth-context'
import { ProtectedRoute } from '@/components/auth/protected-route'
import { MainLayout } from '@/components/layout/main-layout'
import { LoginPage } from '@/pages/auth/login'
import { SignUpPage } from '@/pages/auth/signup'
import { AuthCallback } from '@/pages/auth/callback'
import { DashboardPage } from '@/pages/dashboard'
import { CreateCasePage } from '@/pages/cases/create'
import { CaseDetailsPage } from '@/pages/cases/[id]'
import { LandingPage } from '@/pages/landing'
import { Toaster } from '@/components/ui/toaster'

function App() {
  return (
    <Router>
      <AuthProvider>
        <Routes>
          {/* Public Routes - No Layout */}
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignUpPage />} />
          <Route path="/auth/callback" element={<AuthCallback />} />

          {/* Protected Routes - With Layout */}
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <DashboardPage />
                </MainLayout>
              </ProtectedRoute>
            }
          />

          <Route
            path="/cases/create"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <CreateCasePage />
                </MainLayout>
              </ProtectedRoute>
            }
          />

          <Route
            path="/cases/:id"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <CaseDetailsPage />
                </MainLayout>
              </ProtectedRoute>
            }
          />

          {/* Catch all - redirect to dashboard if authenticated, otherwise to landing */}
          <Route
            path="*"
            element={
              <Navigate to="/" replace />
            }
          />
        </Routes>
        <Toaster />
      </AuthProvider>
    </Router>
  )
}

export default App
