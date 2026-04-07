import { useState } from "react";
import { Search, RotateCcw, Loader2 } from "lucide-react";
import type { Checkout } from "../types";
import StatusBadge from "./StatusBadge";

interface Props {
  checkouts: Checkout[];
  userNames: Record<string, string>;
  title: string;
  showStatus?: boolean;
  showActions?: boolean;
  onReturn?: (checkoutId: string, bookFirestoreId: string) => Promise<void>;
}

function formatDate(date: Date): string {
  return date.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

export default function CheckoutsTable({
  checkouts,
  userNames,
  title,
  showStatus = true,
  showActions = true,
  onReturn,
}: Props) {
  const [searchQuery, setSearchQuery] = useState("");
  const [returningId, setReturningId] = useState<string | null>(null);

  const filtered = checkouts.filter((c) => {
    if (!searchQuery) return true;
    const q = searchQuery.toLowerCase();
    return (
      c.title.toLowerCase().includes(q) ||
      c.author.toLowerCase().includes(q) ||
      (userNames[c.userId] || "").toLowerCase().includes(q)
    );
  });

  async function handleReturn(c: Checkout) {
    if (!onReturn) return;
    if (!confirm(`Check in "${c.title}"? This will mark it as returned.`)) return;
    setReturningId(c.id);
    try {
      await onReturn(c.id, c.bookFirestoreId);
    } catch (err) {
      alert("Error: " + (err instanceof Error ? err.message : "Unknown error"));
    } finally {
      setReturningId(null);
    }
  }

  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
      {/* Header */}
      <div className="px-5 py-4 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h3 className="font-semibold text-slate-900">{title}</h3>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search title, author, student..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9 pr-4 py-2 w-full sm:w-72 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
          />
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="bg-slate-50">
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Book
              </th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Student
              </th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Checked Out
              </th>
              <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                Due Date
              </th>
              {showStatus && (
                <th className="text-left px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                  Status
                </th>
              )}
              {showActions && (
                <th className="text-right px-5 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                  Actions
                </th>
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-5 py-12 text-center text-slate-400 text-sm">
                  {searchQuery ? "No results match your search." : "No checkouts to display."}
                </td>
              </tr>
            ) : (
              filtered.map((c) => (
                <tr key={c.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-5 py-3.5">
                    <div className="font-medium text-sm text-slate-900 line-clamp-1">{c.title}</div>
                    <div className="text-xs text-slate-500">{c.author}</div>
                  </td>
                  <td className="px-5 py-3.5 text-sm text-slate-700">
                    {userNames[c.userId] || c.userId.slice(0, 8) + "..."}
                  </td>
                  <td className="px-5 py-3.5 text-sm text-slate-500">{formatDate(c.checkedOutDate)}</td>
                  <td className="px-5 py-3.5 text-sm text-slate-500">{formatDate(c.dueDate)}</td>
                  {showStatus && (
                    <td className="px-5 py-3.5">
                      <StatusBadge dueDate={c.dueDate} />
                    </td>
                  )}
                  {showActions && (
                    <td className="px-5 py-3.5 text-right">
                      <button
                        onClick={() => handleReturn(c)}
                        disabled={returningId === c.id}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-blue-700 bg-blue-50 hover:bg-blue-100 border border-blue-200 transition-colors disabled:opacity-50"
                      >
                        {returningId === c.id ? (
                          <Loader2 className="w-3.5 h-3.5 animate-spin" />
                        ) : (
                          <RotateCcw className="w-3.5 h-3.5" />
                        )}
                        Check In
                      </button>
                    </td>
                  )}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Footer */}
      <div className="px-5 py-3 border-t border-slate-100 bg-slate-50">
        <p className="text-xs text-slate-400">
          Showing {filtered.length} of {checkouts.length} records
        </p>
      </div>
    </div>
  );
}
