import { BookOpen, LogOut } from "lucide-react";

interface Props {
  email: string;
  onSignOut: () => void;
}

export default function Header({ email, onSignOut }: Props) {
  return (
    <header className="bg-gradient-to-r from-[#1A3C8B] to-[#0F2557] text-white shadow-lg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center gap-3">
            <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-white/10">
              <BookOpen className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="font-bold text-lg tracking-tight">MyBearcatLib</span>
                <span className="text-[10px] font-bold uppercase tracking-wider bg-[#D4952A] text-white px-2 py-0.5 rounded-full">
                  Librarian
                </span>
              </div>
              <p className="text-xs text-blue-200 -mt-0.5">Leontyne Price Library</p>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <span className="text-sm text-blue-200 hidden sm:block">{email}</span>
            <button
              onClick={onSignOut}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm text-blue-200 hover:text-white hover:bg-white/10 transition-colors"
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
