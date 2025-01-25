import { Toaster as RadixToaster } from "sonner"

export function Toaster() {
  return (
    <RadixToaster 
      position="top-right"
      closeButton
      richColors
      expand={false}
    />
  )
} 