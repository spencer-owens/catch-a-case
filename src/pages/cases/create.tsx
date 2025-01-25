import { useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useAuth } from '@/lib/context/auth-context'
import { supabase } from '@/lib/supabase'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { toast } from '@/components/ui/use-toast'

const createCaseSchema = z.object({
  title: z.string().min(1, 'Title is required'),
  description: z.string().min(1, 'Description is required'),
})

type CreateCaseForm = z.infer<typeof createCaseSchema>

export function CreateCasePage() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const queryClient = useQueryClient()

  const form = useForm<CreateCaseForm>({
    resolver: zodResolver(createCaseSchema),
    defaultValues: {
      title: '',
      description: '',
    },
  })

  const createCaseMutation = useMutation({
    mutationFn: async (data: CreateCaseForm) => {
      // First, get the 'Intake' status ID
      const { data: statusData, error: statusError } = await supabase
        .from('statuses')
        .select('id')
        .eq('status_name', 'Intake')
        .single()

      if (statusError) throw statusError

      // Then create the case with the status ID
      const { data: newCase, error: caseError } = await supabase
        .from('cases')
        .insert({
          title: data.title,
          description: data.description,
          client_id: user?.id,
          status_id: statusData.id,
        })
        .select()
        .single()

      if (caseError) throw caseError
      return newCase
    },
    onSuccess: () => {
      // Invalidate the cases query to trigger a refetch
      queryClient.invalidateQueries({ queryKey: ['cases'] })
      
      toast({
        title: 'Case Created',
        description: 'Your case has been successfully created.',
      })

      navigate('/dashboard')
    },
    onError: (error) => {
      console.error('Error creating case:', error)
      toast({
        title: 'Error',
        description: 'There was an error creating your case. Please try again.',
        variant: 'destructive',
      })
    },
  })

  function onSubmit(data: CreateCaseForm) {
    createCaseMutation.mutate(data)
  }

  return (
    <div className="container max-w-2xl py-10">
      <Card>
        <CardHeader>
          <CardTitle>Create New Case</CardTitle>
          <CardDescription>
            Submit a new case for review. We'll assign an agent to assist you shortly.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              <FormField
                control={form.control}
                name="title"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Title</FormLabel>
                    <FormControl>
                      <Input placeholder="Brief title for your case" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="description"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description</FormLabel>
                    <FormControl>
                      <Textarea
                        placeholder="Detailed description of your case"
                        className="min-h-[120px]"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <div className="flex justify-end gap-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate(-1)}
                >
                  Cancel
                </Button>
                <Button 
                  type="submit"
                  disabled={createCaseMutation.isPending}
                >
                  {createCaseMutation.isPending ? 'Creating...' : 'Create Case'}
                </Button>
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  )
} 