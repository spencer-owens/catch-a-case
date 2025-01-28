import * as React from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { MainLayout } from '@/components/layout/main-layout'
import { cn } from '@/lib/utils'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"

const incidents = [
  {
    title: "Car Accident Chaos?",
    description: "Did someone mistake your car for a bumper car at the county fair?",
  },
  {
    title: "Workplace Whoopsie?",
    description: "Boss forgot to mention that 'casual Friday' doesn't mean removing safety equipment?",
  },
  {
    title: "Medical Mayhem?",
    description: "Doctor said it was just a cold, but now you're glowing in the dark?",
  },
  {
    title: "Slip and Slide?",
    description: "Store decided to turn their floor into an ice rink without the ice?",
  },
]

const faqs = [
  {
    question: "How much does it cost to get started?",
    answer: "NOTHING! That's right, we work on contingency - if you don't win, we don't win! No upfront costs, no hidden fees, just justice served with a side of victory! *Terms and conditions apply"
  },
  {
    question: "How long will my case take?",
    answer: "Every case is unique, like a snowflake made of legal documents! While we can't predict exactly how long your case will take, we can promise we'll work faster than your insurance company returns your calls!"
  },
  {
    question: "What types of cases do you handle?",
    answer: "If it hurts, we assert! Personal injury, car accidents, workplace incidents, medical malpractice, slip and falls - if someone wronged you, we'll make it right! We're like legal superheroes, minus the capes (they're not court appropriate)."
  },
  {
    question: "Do I have a case?",
    answer: "If you're asking this question, chances are YES! But don't take our word for it - sign up now and let our expert legal team evaluate your situation. Remember: The only bad case is the one you don't bring to us!"
  },
  {
    question: "What makes you different from other lawyers?",
    answer: "We're not just lawyers, we're your legal avengers! While other firms make you wait, we're already working. While they sleep, we're reviewing cases. While they play golf, we're fighting for YOUR rights! Plus, have you seen our commercials? They're pretty awesome!"
  }
]

function MarqueeText({ children }: { children: React.ReactNode }) {
  return (
    <div className="bg-yellow-300 text-black py-1 px-4 rotate-[-5deg] text-xl font-bold shadow-lg">
      {children}
    </div>
  )
}

function IncidentCard({ title, description, className }: { 
  title: string
  description: string
  className?: string 
}) {
  return (
    <Card className={cn("p-6 border-4 border-primary shadow-xl transform transition-transform hover:scale-105", className)}>
      <h3 className="text-xl font-bold mb-2">{title}</h3>
      <p className="text-muted-foreground">{description}</p>
    </Card>
  )
}

export function LandingPage() {
  const navigate = useNavigate()

  return (
    <MainLayout showNav={false}>
      <div className="container mx-auto px-4 py-12">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <div className="relative inline-block">
            <h1 className="text-6xl font-black mb-6 text-primary">
              HAS THIS EVER HAPPENED TO YOU?
            </h1>
            <MarqueeText>
              CALL NOW! 1-888-555-MITCH
            </MarqueeText>
          </div>
          
          <p className="text-2xl text-muted-foreground mt-8 max-w-2xl mx-auto">
            Life comes at you fast. When it does, you need a legal team that comes at it faster.
          </p>
        </div>

        {/* Incident Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
          {incidents.map((incident, index) => (
            <IncidentCard
              key={incident.title}
              {...incident}
              className={index % 2 === 0 ? "rotate-1" : "-rotate-1"}
            />
          ))}
        </div>

        {/* CTA Section */}
        <div className="text-center mb-24">
          <div className="inline-block bg-primary/10 p-8 rounded-lg mb-8 transform -rotate-2">
            <h2 className="text-4xl font-bold mb-4">
              Don't Wait! Justice Can't!
            </h2>
            <p className="text-xl text-muted-foreground mb-8">
              Our legal team is standing by 24/7 to catch your case!
            </p>
            <div className="space-x-4">
              <Button
                size="lg"
                className="text-lg px-8 animate-pulse"
                onClick={() => navigate('/signup')}
              >
                Start Your Case Now!
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="text-lg px-8"
                onClick={() => navigate('/login')}
              >
                Existing Client? Sign In
              </Button>
            </div>
          </div>
          
          <p className="text-sm text-muted-foreground">
            * Results may vary. But our enthusiasm never does! 
          </p>
        </div>

        {/* FAQ Section */}
        <div className="max-w-3xl mx-auto mb-16">
          <div className="text-center mb-12">
            <MarqueeText>
              BUT WAIT, THERE'S MORE!
            </MarqueeText>
            <h2 className="text-4xl font-bold mt-6 mb-4">
              Frequently Asked Questions
            </h2>
            <p className="text-xl text-muted-foreground">
              Everything you need to know about getting the justice you deserve!
            </p>
          </div>

          <Card className="p-6 border-4 border-primary">
            <Accordion type="single" collapsible className="w-full">
              {faqs.map((faq, index) => (
                <AccordionItem key={index} value={`item-${index}`}>
                  <AccordionTrigger className="text-lg font-bold hover:text-primary">
                    {faq.question}
                  </AccordionTrigger>
                  <AccordionContent className="text-muted-foreground">
                    {faq.answer}
                  </AccordionContent>
                </AccordionItem>
              ))}
            </Accordion>
          </Card>

          <div className="text-center mt-8">
            <Button
              size="lg"
              className="text-lg px-8 animate-pulse"
              onClick={() => navigate('/signup')}
            >
              Get Your FREE Case Evaluation Now!
            </Button>
          </div>
        </div>
      </div>
    </MainLayout>
  )
} 