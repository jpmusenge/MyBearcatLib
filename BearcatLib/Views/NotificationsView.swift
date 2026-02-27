//
//  NotificationsView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/26/26.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
        
    // Using the mock data in SampleData
    let announcements = SampleData.announcements
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                if announcements.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(announcements) { announcement in
                                NotificationCard(announcement: announcement)
                            }
                        }
                        .padding(.horizontal, Theme.Layout.paddingLarge)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            
            Text("No new notifications")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("We'll let you know when you have upcoming due dates or library news.")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

// MARK: - Notification Card
struct NotificationCard: View {
    let announcement: Announcement
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Indicator
            ZStack {
                Circle()
                    .fill(announcement.isUrgent ? Theme.Colors.error.opacity(0.15) : Theme.Colors.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: announcement.isUrgent ? "exclamationmark.triangle.fill" : "megaphone.fill")
                    .font(.system(size: 18))
                    .foregroundColor(announcement.isUrgent ? Theme.Colors.error : Theme.Colors.primary)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(announcement.title)
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(announcement.date)
                        .font(.custom("AvenirNext-Regular", size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Text(announcement.summary)
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
    }
}

#Preview {
    NotificationsView()
}
