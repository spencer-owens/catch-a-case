import { SignUpForm } from '../../components/auth/signup-form'
import { Link } from 'react-router-dom'
import { MainLayout } from '../../components/layout/main-layout'

export function SignUpPage() {
  return (
    <MainLayout showNav={false} className="flex items-center justify-center min-h-screen">
      <div className="w-full max-w-md">
        <h1 className="text-4xl font-bold text-center mb-8">Catch a Case</h1>
        <SignUpForm />
        <p className="text-center mt-4 text-sm text-muted-foreground">
          Already have an account?{' '}
          <Link to="/login" className="text-primary hover:underline">
            Sign in
          </Link>
        </p>
      </div>
    </MainLayout>
  )
} 