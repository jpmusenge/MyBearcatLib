import { useAuth } from "./hooks/useAuth";
import LoginPage from "./components/LoginPage";
import Dashboard from "./components/Dashboard";
import { Loader2 } from "lucide-react";

export default function App() {
  const { user, loading, signIn, signOut } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-blue-600 animate-spin" />
      </div>
    );
  }

  if (!user) {
    return (
      <LoginPage
        onSignIn={async (email, password) => {
          await signIn(email, password);
        }}
      />
    );
  }

  return <Dashboard email={user.email || ""} onSignOut={signOut} />;
}
