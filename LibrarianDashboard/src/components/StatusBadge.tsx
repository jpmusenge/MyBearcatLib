import { daysUntilDue } from "../hooks/useCheckouts";

interface Props {
  dueDate: Date;
}

export default function StatusBadge({ dueDate }: Props) {
  const days = daysUntilDue(dueDate);

  if (days < 0) {
    return (
      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-red-100 text-red-800">
        Overdue {Math.abs(days)}d
      </span>
    );
  }
  if (days === 0) {
    return (
      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-amber-100 text-amber-800">
        Due Today
      </span>
    );
  }
  if (days <= 3) {
    return (
      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-amber-100 text-amber-800">
        Due in {days}d
      </span>
    );
  }
  return (
    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800">
      Due in {days}d
    </span>
  );
}
