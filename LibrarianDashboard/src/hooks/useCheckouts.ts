import { useState, useEffect } from "react";
import {
  collection,
  query,
  where,
  onSnapshot,
  doc,
  writeBatch,
  getDoc,
} from "firebase/firestore";
import { db } from "../lib/firebase";
import type { Checkout, Borrower } from "../types";

// Cache user display names
const nameCache: Record<string, string> = {};

async function resolveUserName(userId: string): Promise<string> {
  if (nameCache[userId]) return nameCache[userId];
  try {
    const snap = await getDoc(doc(db, "users", userId));
    if (snap.exists()) {
      const data = snap.data();
      const name = data.displayName || data.name || data.email || userId.slice(0, 8) + "...";
      nameCache[userId] = name;
      return name;
    }
  } catch {
    // ignore
  }
  nameCache[userId] = userId.slice(0, 8) + "...";
  return nameCache[userId];
}

export function daysUntilDue(dueDate: Date): number {
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  const due = new Date(dueDate);
  due.setHours(0, 0, 0, 0);
  return Math.ceil((due.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
}

export function useCheckouts() {
  const [checkouts, setCheckouts] = useState<Checkout[]>([]);
  const [userNames, setUserNames] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(
      collection(db, "checkouts"),
      where("isReturned", "==", false)
    );

    const unsub = onSnapshot(q, async (snapshot) => {
      const items: Checkout[] = snapshot.docs.map((d) => {
        const data = d.data();
        return {
          id: d.id,
          userId: data.userId,
          bookFirestoreId: data.bookFirestoreId,
          title: data.title || "Untitled",
          author: data.author || "Unknown",
          isbn: data.isbn || "",
          checkedOutDate: data.checkedOutDate?.toDate?.() || new Date(),
          dueDate: data.dueDate?.toDate?.() || new Date(),
          renewCount: data.renewCount || 0,
          isReturned: data.isReturned || false,
        };
      });

      // Resolve all user names
      const uniqueIds = [...new Set(items.map((c) => c.userId))];
      const names: Record<string, string> = {};
      await Promise.all(
        uniqueIds.map(async (uid) => {
          names[uid] = await resolveUserName(uid);
        })
      );

      setUserNames(names);
      setCheckouts(items.sort((a, b) => daysUntilDue(a.dueDate) - daysUntilDue(b.dueDate)));
      setLoading(false);
    });

    return unsub;
  }, []);

  const overdueCheckouts = checkouts.filter((c) => daysUntilDue(c.dueDate) < 0);
  const dueSoonCheckouts = checkouts.filter((c) => {
    const d = daysUntilDue(c.dueDate);
    return d >= 0 && d <= 3;
  });

  const borrowers: Borrower[] = (() => {
    const map: Record<string, Borrower> = {};
    checkouts.forEach((c) => {
      if (!map[c.userId]) {
        map[c.userId] = {
          userId: c.userId,
          displayName: userNames[c.userId] || c.userId,
          bookCount: 0,
          overdueCount: 0,
          nextDue: null,
        };
      }
      map[c.userId].bookCount++;
      if (daysUntilDue(c.dueDate) < 0) map[c.userId].overdueCount++;
      if (!map[c.userId].nextDue || c.dueDate < map[c.userId].nextDue!) {
        map[c.userId].nextDue = c.dueDate;
      }
    });
    return Object.values(map).sort((a, b) => b.overdueCount - a.overdueCount || b.bookCount - a.bookCount);
  })();

  async function returnBook(checkoutId: string, bookFirestoreId: string) {
    const batch = writeBatch(db);
    batch.update(doc(db, "checkouts", checkoutId), { isReturned: true });
    if (bookFirestoreId) {
      batch.update(doc(db, "books", bookFirestoreId), { isAvailable: true });
    }
    await batch.commit();
  }

  return {
    checkouts,
    overdueCheckouts,
    dueSoonCheckouts,
    borrowers,
    userNames,
    loading,
    returnBook,
  };
}
