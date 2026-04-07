import { useState } from "react";
import { BookOpen, AlertTriangle, Clock, Users, Loader2 } from "lucide-react";
import { useCheckouts } from "../hooks/useCheckouts";
import type { TabId } from "../types";
import Header from "./Header";
import StatsCards from "./StatsCards";
import CheckoutsTable from "./CheckoutsTable";
import BorrowersTable from "./BorrowersTable";

interface Props {
  email: string;
  onSignOut: () => void;
}

const tabs: { id: TabId; label: string; icon: typeof BookOpen }[] = [
  { id: "all", label: "All Checkouts", icon: BookOpen },
  { id: "overdue", label: "Overdue", icon: AlertTriangle },
  { id: "due-soon", label: "Due Soon", icon: Clock },
  { id: "borrowers", label: "Borrowers", icon: Users },
];

export default function Dashboard({ email, onSignOut }: Props) {
  const [activeTab, setActiveTab] = useState<TabId>("all");
  const {
    checkouts,
    overdueCheckouts,
    dueSoonCheckouts,
    borrowers,
    userNames,
    loading,
    returnBook,
  } = useCheckouts();

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50">
        <Header email={email} onSignOut={onSignOut} />
        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <Loader2 className="w-8 h-8 text-blue-600 animate-spin mx-auto mb-3" />
            <p className="text-sm text-slate-500">Loading dashboard...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <Header email={email} onSignOut={onSignOut} />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
        {/* Stats */}
        <StatsCards
          total={checkouts.length}
          overdue={overdueCheckouts.length}
          dueSoon={dueSoonCheckouts.length}
          borrowers={borrowers.length}
        />

        {/* Tabs */}
        <div className="border-b border-slate-200">
          <nav className="flex gap-1 -mb-px">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
                  activeTab === tab.id
                    ? "border-[#1A3C8B] text-[#1A3C8B]"
                    : "border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300"
                }`}
              >
                <tab.icon className="w-4 h-4" />
                {tab.label}
                {tab.id === "overdue" && overdueCheckouts.length > 0 && (
                  <span className="ml-1 px-1.5 py-0.5 text-[10px] font-bold rounded-full bg-red-100 text-red-700">
                    {overdueCheckouts.length}
                  </span>
                )}
              </button>
            ))}
          </nav>
        </div>

        {/* Tab Content */}
        {activeTab === "all" && (
          <CheckoutsTable
            checkouts={checkouts}
            userNames={userNames}
            title={`All Active Checkouts (${checkouts.length})`}
            onReturn={returnBook}
          />
        )}
        {activeTab === "overdue" && (
          <CheckoutsTable
            checkouts={overdueCheckouts}
            userNames={userNames}
            title={`Overdue Books (${overdueCheckouts.length})`}
            onReturn={returnBook}
          />
        )}
        {activeTab === "due-soon" && (
          <CheckoutsTable
            checkouts={dueSoonCheckouts}
            userNames={userNames}
            title={`Due Within 3 Days (${dueSoonCheckouts.length})`}
            showActions={false}
          />
        )}
        {activeTab === "borrowers" && <BorrowersTable borrowers={borrowers} />}
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-200 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-xs text-slate-400">
            MyBearcatLib Librarian Dashboard v1.0 &middot; Leontyne Price Library &middot; Rust College
          </p>
        </div>
      </footer>
    </div>
  );
}
