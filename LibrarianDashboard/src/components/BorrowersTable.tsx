import { useState } from "react";
import { Search } from "lucide-react";
import type { Borrower } from "../types";

interface Props {
  borrowers: Borrower[];
}

function formatDate(date: Date | null): string {
  if (!date) return "-";
  return date.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

export default function BorrowersTable({ borrowers }: Props) {
  const [searchQuery, setSearchQuery] = useState("");

  const filtered = borrowers.filter((b) => {
    if (!searchQuery) return true;
    return b.displayName.toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
      <div className="px-5 py-4 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h3 className="font-semibold text-slate-900">Active Borrowers</h3>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search students..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9 pr-4 py-2 w-full sm:w-64 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
          />
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="bg-slate-50">
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Student
              </th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Books Borrowed
              </th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Overdue
              </th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Next Due
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.length === 0 ? (
              <tr>
                <td colSpan={4} className="px-5 py-12 text-center text-slate-400 text-sm">
                  {searchQuery ? "No results match your search." : "No active borrowers."}
                </td>
              </tr>
            ) : (
              filtered.map((b) => (
                <tr key={b.userId} className="hover:bg-slate-50 transition-colors">
                  <td className="px-5 py-3.5">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-xs font-bold">
                        {b.displayName.charAt(0).toUpperCase()}
                      </div>
                      <span className="text-sm font-medium text-slate-900">{b.displayName}</span>
                    </div>
                  </td>
                  <td className="px-5 py-3.5 text-sm text-slate-700">{b.bookCount}</td>
                  <td className="px-5 py-3.5">
                    {b.overdueCount > 0 ? (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-red-100 text-red-800">
                        {b.overdueCount}
                      </span>
                    ) : (
                      <span className="text-sm text-emerald-600 font-medium">0</span>
                    )}
                  </td>
                  <td className="px-5 py-3.5 text-sm text-slate-500">{formatDate(b.nextDue)}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <div className="px-5 py-3 border-t border-slate-100 bg-slate-50">
        <p className="text-xs text-slate-400">
          {filtered.length} borrower{filtered.length !== 1 ? "s" : ""}
        </p>
      </div>
    </div>
  );
}
