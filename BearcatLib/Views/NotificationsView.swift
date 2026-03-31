//
//  NotificationsView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/26/26.
//

// PURPOSE: Shows library notifications — due date alerts from checkouts + library announcements

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var checkoutService: CheckoutService

    let announcements = SampleData.announcements

    var body: some View {
        List {
            // MARK: - Due Date Alerts
            if !checkoutAlerts.isEmpty {
                Section("Due Date Alerts") {
                    ForEach(checkoutAlerts, id: \.id) { alert in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(alert.color.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: alert.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(alert.color)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(alert.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)

                                Text(alert.message)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            // MARK: - Library Announcements
            if !announcements.isEmpty {
                Section("Library News") {
                    ForEach(announcements) { announcement in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(announcement.isUrgent ? Theme.Colors.error.opacity(0.15) : Theme.Colors.primary.opacity(0.1))
                                    .frame(width: 36, height: 36)

                                Image(systemName: announcement.isUrgent ? "exclamationmark.triangle.fill" : "megaphone.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(announcement.isUrgent ? Theme.Colors.error : Theme.Colors.primary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(announcement.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)

                                    Spacer()

                                    Text(announcement.date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Text(announcement.summary)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            // MARK: - Empty State
            if checkoutAlerts.isEmpty && announcements.isEmpty {
                ContentUnavailableView {
                    Label("No Notifications", systemImage: "bell.slash")
                } description: {
                    Text("You're all caught up. Due date reminders and library news will appear here.")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
    }

    // MARK: - Build Alerts from Checkouts

    private struct CheckoutAlert: Identifiable {
        let id: String
        let icon: String
        let color: Color
        let title: String
        let message: String
        let daysUntilDue: Int
    }

    private var checkoutAlerts: [CheckoutAlert] {
        checkoutService.userCheckouts.compactMap { checkout in
            if checkout.isOverdue {
                return CheckoutAlert(
                    id: checkout.id,
                    icon: "exclamationmark.circle.fill",
                    color: Theme.Colors.error,
                    title: checkout.title,
                    message: "\(checkout.statusText) — please return or renew.",
                    daysUntilDue: checkout.daysUntilDue
                )
            } else if checkout.isDueSoon {
                return CheckoutAlert(
                    id: checkout.id,
                    icon: "clock.fill",
                    color: .orange,
                    title: checkout.title,
                    message: "\(checkout.statusText). Due \(checkout.formattedDueDate).",
                    daysUntilDue: checkout.daysUntilDue
                )
            }
            return nil
        }
        .sorted { $0.daysUntilDue < $1.daysUntilDue }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(CheckoutService.shared)
    }
}
