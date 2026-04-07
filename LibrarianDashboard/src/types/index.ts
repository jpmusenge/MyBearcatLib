export interface Checkout {
  id: string;
  userId: string;
  bookFirestoreId: string;
  title: string;
  author: string;
  isbn: string;
  checkedOutDate: Date;
  dueDate: Date;
  renewCount: number;
  isReturned: boolean;
}

export interface Borrower {
  userId: string;
  displayName: string;
  bookCount: number;
  overdueCount: number;
  nextDue: Date | null;
}

export type TabId = "all" | "overdue" | "due-soon" | "borrowers";
