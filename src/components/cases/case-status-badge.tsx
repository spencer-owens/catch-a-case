import { Badge } from "@/components/ui/badge"

interface CaseStatusBadgeProps {
  status: string
}

export function CaseStatusBadge({ status }: CaseStatusBadgeProps) {
  const variantMap: Record<string, "default" | "secondary" | "destructive"> = {
    Intake: "default",
    "Pre-litigation": "secondary",
    Litigation: "destructive",
    Settlement: "secondary",
    Closed: "default",
  }

  return (
    <Badge variant={variantMap[status] || "default"}>
      {status}
    </Badge>
  )
} 