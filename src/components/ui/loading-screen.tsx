import { cn } from "@/lib/utils"

interface LoadingScreenProps {
  className?: string
}

export function LoadingScreen({ className }: LoadingScreenProps) {
  return (
    <div className={cn(
      "min-h-screen bg-background flex items-center justify-center",
      className
    )}>
      <div className="space-y-4 text-center">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto" />
        <p className="text-sm text-muted-foreground">Loading...</p>
      </div>
    </div>
  )
} 