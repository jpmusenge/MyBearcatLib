import { BookOpen, AlertTriangle, Clock, Users } from "lucide-react";

interface Props {
  total: number;
  overdue: number;
  dueSoon: number;
  borrowers: number;
}

export default function StatsCards({ total, overdue, dueSoon, borrowers }: Props) {
  const cards = [
    {
      label: "Active Checkouts",
      value: total,
      icon: BookOpen,
      color: "text-blue-600",
      bg: "bg-blue-50",
      border: "border-blue-200",
    },
    {
      label: "Overdue Books",
      value: overdue,
      icon: AlertTriangle,
      color: "text-red-600",
      bg: "bg-red-50",
      border: "border-red-200",
    },
    {
      label: "Due Within 3 Days",
      value: dueSoon,
      icon: Clock,
      color: "text-amber-600",
      bg: "bg-amber-50",
      border: "border-amber-200",
    },
    {
      label: "Active Borrowers",
      value: borrowers,
      icon: Users,
      color: "text-emerald-600",
      bg: "bg-emerald-50",
      border: "border-emerald-200",
    },
  ];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {cards.map((card) => (
        <div
          key={card.label}
          className={`${card.bg} ${card.border} border rounded-xl p-5`}
        >
          <div className="flex items-center justify-between mb-3">
            <card.icon className={`w-5 h-5 ${card.color}`} />
          </div>
          <div className={`text-3xl font-bold ${card.color}`}>{card.value}</div>
          <div className="text-sm text-slate-500 mt-1">{card.label}</div>
        </div>
      ))}
    </div>
  );
}
