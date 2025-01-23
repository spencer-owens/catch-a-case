import { Button } from "./components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "./components/ui/card"
import { useTheme } from "./lib/context/theme-context"

function App() {
  const { theme, setTheme } = useTheme()

  return (
    <div className="min-h-screen bg-background p-8 flex flex-col items-center gap-4">
      <div className="w-full max-w-4xl flex justify-between items-center mb-8">
        <h1 className="text-4xl font-bold text-foreground">Catch a Case</h1>
        <Button 
          variant="outline"
          onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
        >
          Toggle {theme === 'light' ? 'Dark' : 'Light'} Mode
        </Button>
      </div>
      
      <Card className="w-[350px]">
        <CardHeader>
          <CardTitle>Create project</CardTitle>
          <CardDescription>Deploy your new project in one-click.</CardDescription>
        </CardHeader>
        <CardContent>
          <p>Your new project will be created in your organization.</p>
        </CardContent>
        <CardFooter className="flex justify-between">
          <Button variant="outline">Cancel</Button>
          <Button>Deploy</Button>
        </CardFooter>
      </Card>

      <div className="flex gap-4 mt-8">
        <Button>Default Button</Button>
        <Button variant="secondary">Secondary</Button>
        <Button variant="destructive">Destructive</Button>
        <Button variant="outline">Outline</Button>
      </div>
    </div>
  )
}

export default App
