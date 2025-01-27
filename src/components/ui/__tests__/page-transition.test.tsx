import { render, screen } from '@testing-library/react'
import { PageTransition } from '../page-transition'
import { describe, it, expect } from 'vitest'

describe('PageTransition', () => {
  it('renders children content', () => {
    render(
      <PageTransition>
        <div>Test Content</div>
      </PageTransition>
    )

    expect(screen.getByText('Test Content')).toBeInTheDocument()
  })

  it('applies custom className', () => {
    render(
      <PageTransition className="custom-class">
        <div>Test Content</div>
      </PageTransition>
    )

    const element = screen.getByText('Test Content').parentElement
    expect(element).toHaveClass('custom-class')
  })

  it('starts with initial animation state', () => {
    render(
      <PageTransition>
        <div>Test Content</div>
      </PageTransition>
    )

    const element = screen.getByText('Test Content').parentElement
    expect(element).toHaveClass('opacity-0', 'translate-y-4')
  })
}) 