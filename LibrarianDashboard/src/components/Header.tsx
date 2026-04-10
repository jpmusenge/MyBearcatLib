import { BookOpen, LogOut } from "lucide-react";
import Logo from "./Logo";

interface Props {
  email: string;
  onSignOut: () => void;
}

export default function Header({ email, onSignOut }: Props) {
  return (
    <header className="bg-gradient-to-r from-[#1A3C8B] to-[#0F2557] text-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center gap-3">
            {/* Custom SVG Logo replacing the standard white box */}
            <Logo className="w-10 h-10 drop-shadow-md" />
            
            <div className="flex flex-col justify-center">
              <div className="flex items-center gap-2">
                <span className="font-bold text-lg tracking-tight">MyBearcatLib</span>
                <span className="text-[9px] font-bold uppercase tracking-wider bg-[#D4952A] text-white px-2 py-0.5 rounded-full">
                  Librarian
                </span>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <span className="text-sm text-blue-200 hidden sm:block font-medium">{email}</span>
            <button
              onClick={onSignOut}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium text-blue-100 hover:text-white hover:bg-white/10 transition-colors"
            >
              <LogOut className="w-4 h-4" />
              <span className="hidden sm:inline">Sign Out</span>
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
