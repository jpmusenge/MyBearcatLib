// import { BookOpen, AlertTriangle, Clock, Users } from "lucide-react";

// interface Props {
//   total: number;
//   overdue: number;
//   dueSoon: number;
//   borrowers: number;
// }

// export default function StatsCards({ total, overdue, dueSoon, borrowers }: Props) {
//   const cards = [
//     {
//       label: "Active Checkouts",
//       value: total,
//       icon: BookOpen,
//       color: "text-blue-600",
//       bg: "bg-blue-50",
//       border: "border-blue-200",
//     },
//     {
//       label: "Overdue Books",
//       value: overdue,
//       icon: AlertTriangle,
//       color: "text-red-600",
//       bg: "bg-red-50",
//       border: "border-red-200",
//     },
//     {
//       label: "Due Within 3 Days",
//       value: dueSoon,
//       icon: Clock,
//       color: "text-amber-600",
//       bg: "bg-amber-50",
//       border: "border-amber-200",
//     },
//     {
//       label: "Active Borrowers",
//       value: borrowers,
//       icon: Users,
//       color: "text-emerald-600",
//       bg: "bg-emerald-50",
//       border: "border-emerald-200",
//     },
//   ];

//   return (
//     <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
//       {cards.map((card) => (
//         <div
//           key={card.label}
//           className={`${card.bg} ${card.border} border rounded-xl p-5`}
//         >
//           <div className="flex items-center justify-between mb-3">
//             <card.icon className={`w-5 h-5 ${card.color}`} />
//           </div>
//           <div className={`text-3xl font-bold ${card.color}`}>{card.value}</div>
//           <div className="text-sm text-slate-500 mt-1">{card.label}</div>
//         </div>
//       ))}
//     </div>
//   );
// }

// src/components/StatsCards.tsx
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
      iconColor: "text-blue-600",
      iconBg: "bg-blue-50",
    },
    {
      label: "Overdue Books",
      value: overdue,
      icon: AlertTriangle,
      iconColor: "text-red-600",
      iconBg: "bg-red-50",
    },
    {
      label: "Due Within 3 Days",
      value: dueSoon,
      icon: Clock,
      iconColor: "text-amber-600",
      iconBg: "bg-amber-50",
    },
    {
      label: "Active Borrowers",
      value: borrowers,
      icon: Users,
      iconColor: "text-emerald-600",
      iconBg: "bg-emerald-50",
    },
  ];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {cards.map((card) => (
        <div
          key={card.label}
          className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex flex-col"
        >
          <div className="flex items-center gap-3 mb-3">
            <div className={`p-2 rounded-lg ${card.iconBg}`}>
              <card.icon className={`w-5 h-5 ${card.iconColor}`} />
            </div>
            <span className="text-sm font-medium text-slate-500">{card.label}</span>
          </div>
          <div className="text-3xl font-bold text-slate-900 mt-auto">{card.value}</div>
        </div>
      ))}
    </div>
  );
}