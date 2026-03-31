//
//  ProfileView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/1/26.
//

// PURPOSE: Student profile screen — account info, library stats, settings, and sign out
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var checkoutService: CheckoutService
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Identity Header
                Section {
                    HStack(spacing: 16) {
                        // Using a high-contrast circle for a professional look
                        Text(authViewModel.userInitials)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.Colors.primaryLight, Theme.Colors.primaryDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authViewModel.userDisplayName)
                                .font(.headline)
                            
                            Text("ID: RC-2026-0471")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Computer Science · Senior")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(AdaptiveColors.surface(settings.isDarkMode))

                // MARK: - Activity Stats
                Section("Library Activity") {
                    HStack {
                        DetailStat(label: "Borrowed", value: "\(checkoutService.userCheckouts.count)")
                        Divider().padding(.vertical, 4)
                        DetailStat(
                            label: "Overdue",
                            value: "\(checkoutService.overdueCheckouts.count)",
                            color: checkoutService.overdueCheckouts.isEmpty ? .primary : Theme.Colors.error
                        )
                        Divider().padding(.vertical, 4)
                        DetailStat(label: "Fines", value: "$0.00")
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(AdaptiveColors.surface(settings.isDarkMode))

                // MARK: - Preferences
                Section("Preferences") {
                    Toggle(isOn: $settings.isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .tint(Theme.Colors.primary)

                    NavigationLink {
                        NotificationsView()
                    } label: {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }
                .listRowBackground(AdaptiveColors.surface(settings.isDarkMode))

                // MARK: - Support
                Section("Support") {
                    Link(destination: URL(string: "https://rustcollege.edu/leontyne-price-library/")!) {
                        Label("Library Website", systemImage: "safari")
                    }
                    NavigationLink("Report an Issue") { Text("Support Form") }
                    NavigationLink("Privacy Policy") { Text("Privacy Policy Content") }
                }
                .listRowBackground(AdaptiveColors.surface(settings.isDarkMode))

                // MARK: - Account Actions
                Section {
                    Button(role: .destructive) {
                        showSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                }
                .listRowBackground(AdaptiveColors.surface(settings.isDarkMode))
                
                // Version Footer
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            Text("BearcatLib v1.0.0")
                            Text("Rust College · Leontyne Price Library")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Account")
            .confirmationDialog("Sign Out", isPresented: $showSignOutAlert, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out of BearcatLib?")
            }
        }
    }
}

// Professional Stat Subcomponent
struct DetailStat: View {
    let label: String
    let value: String
    var color: Color = .primary
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppSettings())
        .environmentObject(CheckoutService.shared)
}
