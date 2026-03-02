//
//  ProfileView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/1/26.
//

// PURPOSE: Student profile screen — account info, library stats, settings, and sign out

import SwiftUI

struct ProfileView: View {
    
    // MARK: - State
    @State private var showSignOutAlert = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    // Pull checked-out data for stats
    private let checkedOutBooks = SampleData.checkedOutBooks
    private let totalBooks = SampleData.books.count
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // Premium profile header card
                    profileHeader
                    statsSection
                    accountSection
                    settingsSection
                    supportSection
                    signOutButton
                    versionFooter
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    // Auth sign-out will go here later
                }
            } message: {
                Text("Are you sure you want to sign out of BearcatLib?")
            }
        }
    }
    
    // MARK: - Profile Header Card
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Avatar + Name
            HStack(spacing: 16) {
                // Avatar circle with initials
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 72, height: 72)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 72, height: 72)
                    
                    Text("JM")
                        .font(.custom("AvenirNext-Bold", size: 26))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Joseph Musenge")
                        .font(Theme.Fonts.title2)
                        .foregroundColor(.white)
                    
                    Text("Computer Science · Senior")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Student ID badge
                    Text("ID: RC-2026-0471")
                        .font(.custom("AvenirNext-Medium", size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            
            // Membership status bar
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.accentLight)
                
                Text("Active Library Member")
                    .font(.custom("AvenirNext-DemiBold", size: 13))
                    .foregroundColor(.white.opacity(0.85))
                
                Spacer()
                
                Text("Since Aug 2022")
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(12)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Theme.Colors.primaryLight, Theme.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 15, x: 0, y: 8)
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Library Activity")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Layout.paddingLarge)
            
            HStack(spacing: 12) {
                StatCard(
                    value: "\(checkedOutBooks.count)",
                    label: "Checked Out",
                    icon: "book.closed.fill",
                    color: Theme.Colors.primary
                )
                
                StatCard(
                    value: "24",
                    label: "Books Read",
                    icon: "text.book.closed.fill",
                    color: Theme.Colors.accent
                )
                
                StatCard(
                    value: "0",
                    label: "Fines",
                    icon: "dollarsign.circle.fill",
                    color: Theme.Colors.success
                )
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)
        }
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Layout.paddingLarge)
            
            VStack(spacing: 0) {
                ProfileRow(icon: "envelope.fill", title: "Email", detail: "jmusenge@rustcollege.edu")
                
                Divider().padding(.leading, 56)
                
                ProfileRow(icon: "phone.fill", title: "Phone", detail: "(662) 555-0147")
                
                Divider().padding(.leading, 56)
                
                ProfileRow(icon: "building.columns.fill", title: "Library", detail: "Leontyne Price Library")
                
                Divider().padding(.leading, 56)
                
                ProfileRow(icon: "graduationcap.fill", title: "Major", detail: "Computer Science")
            }
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
            .padding(.horizontal, Theme.Layout.paddingLarge)
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Layout.paddingLarge)
            
            VStack(spacing: 0) {
                // Notification toggle
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.Colors.accent.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.accent)
                    }
                    
                    Text("Due Date Reminders")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(Theme.Colors.primary)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                Divider().padding(.leading, 56)
                
                // Dark mode toggle
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.Colors.primary.opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image(systemName: "moon.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.primary)
                    }
                    
                    Text("Dark Mode")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $darkModeEnabled)
                        .tint(Theme.Colors.primary)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
            .padding(.horizontal, Theme.Layout.paddingLarge)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Help & Support")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Layout.paddingLarge)
            
            VStack(spacing: 0) {
                ProfileNavigationRow(icon: "questionmark.circle.fill", title: "FAQ & Help", color: Theme.Colors.primary)
                
                Divider().padding(.leading, 56)
                
                ProfileNavigationRow(icon: "exclamationmark.bubble.fill", title: "Report a Problem", color: Theme.Colors.warning)
                
                Divider().padding(.leading, 56)
                
                ProfileNavigationRow(icon: "hand.raised.fill", title: "Privacy Policy", color: Theme.Colors.textSecondary)
            }
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
            .padding(.horizontal, Theme.Layout.paddingLarge)
        }
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button(action: {
            showSignOutAlert = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sign Out")
                    .font(Theme.Fonts.headline)
            }
            .foregroundColor(Theme.Colors.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.Colors.error.opacity(0.08))
            .cornerRadius(Theme.Layout.cornerRadius)
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    // MARK: - Version Footer
    private var versionFooter: some View {
        VStack(spacing: 4) {
            Text("BearcatLib")
                .font(.custom("AvenirNext-DemiBold", size: 13))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.6))
            Text("Version 1.0.0 · Rust College")
                .font(.custom("AvenirNext-Regular", size: 12))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Subcomponents

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
    }
}

private struct ProfileRow: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Text(title)
                .font(Theme.Fonts.headline)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            Text(detail)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct ProfileNavigationRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
