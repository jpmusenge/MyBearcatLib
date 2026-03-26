////
////  MyBooksView.swift
////  BearcatLib
////
////  Created by Joseph Musenge on 2/22/26.

import SwiftUI

struct MyBooksView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var checkoutService: CheckoutService
    private var dk: Bool { settings.isDarkMode }

    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveColors.background(dk).ignoresSafeArea()

                if checkoutService.isLoading {
                    ProgressView("Loading your books...")
                } else if checkoutService.userCheckouts.isEmpty {
                    emptyStateView
                } else {
                    List {
                        // MARK: - Summary Section
                        Section {
                            HStack(spacing: 0) {
                                SummaryStat(
                                    label: "Borrowed",
                                    value: "\(checkoutService.userCheckouts.count)"
                                )

                                Divider().frame(height: 30).padding(.horizontal, 10)

                                SummaryStat(
                                    label: "Overdue",
                                    value: "\(checkoutService.overdueCheckouts.count)",
                                    color: checkoutService.overdueCheckouts.isEmpty ? .primary : Theme.Colors.error
                                )

                                Divider().frame(height: 30).padding(.horizontal, 10)

                                SummaryStat(
                                    label: "Next Due",
                                    value: checkoutService.nextDueLabel
                                )
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(AdaptiveColors.surface(dk))

                        // MARK: - Overdue Section
                        if !checkoutService.overdueCheckouts.isEmpty {
                            Section("Overdue") {
                                ForEach(checkoutService.overdueCheckouts) { checkout in
                                    CheckoutRow(checkout: checkout)
                                }
                            }
                        }

                        // MARK: - Active Loans Section
                        if !checkoutService.activeCheckouts.isEmpty {
                            Section("Currently Borrowed") {
                                ForEach(checkoutService.activeCheckouts) { checkout in
                                    CheckoutRow(checkout: checkout)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        // Pull-to-refresh: restart listener
                        checkoutService.stopListening()
                        checkoutService.startListening()
                    }
                }
            }
            .navigationTitle("My Books")
            .overlay {
                if let error = checkoutService.errorMessage {
                    VStack {
                        Text(error)
                            .font(.system(.caption))
                            .foregroundColor(Theme.Colors.error)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    // MARK: - Subcomponents

    private func SummaryStat(label: String, value: String, color: Color = .primary) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Books Checked Out", systemImage: "books.vertical")
        } description: {
            Text("Books you borrow from Leontyne Price Library will appear here.")
        }
    }
}

// MARK: - Checkout Row

struct CheckoutRow: View {
    let checkout: Checkout
    @EnvironmentObject var checkoutService: CheckoutService
    @State private var isRenewing = false
    @State private var isReturning = false
    @State private var showReturnConfirm = false
    @State private var showError = false
    @State private var errorText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Book initial
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.1))
                    Text(checkout.title.prefix(1))
                        .font(.system(.body, design: .serif, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .frame(width: 36, height: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text(checkout.title)
                        .font(.system(.subheadline, weight: .semibold))
                        .lineLimit(1)

                    Text(checkout.author)
                        .font(.system(.caption))
                        .foregroundColor(.secondary)

                    Text(checkout.statusText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(checkout.isOverdue ? .red : Theme.Colors.primary)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 6) {
                    if checkout.canRenew {
                        Button {
                            renewBook()
                        } label: {
                            if isRenewing {
                                ProgressView().controlSize(.small)
                            } else {
                                Text("Renew")
                            }
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                        .tint(Theme.Colors.primary)
                        .disabled(isRenewing)
                    }

                    Button {
                        showReturnConfirm = true
                    } label: {
                        if isReturning {
                            ProgressView().controlSize(.small)
                        } else {
                            Text("Return")
                        }
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .tint(.secondary)
                    .disabled(isReturning)
                }
            }

            // Due date and renewal info
            HStack {
                Text("Due: \(checkout.formattedDueDate)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                if checkout.renewCount > 0 {
                    Text("Renewed \(checkout.renewCount)/2")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog("Return Book", isPresented: $showReturnConfirm) {
            Button("Return \"\(checkout.title)\"", role: .destructive) {
                returnBook()
            }
        } message: {
            Text("This will mark the book as returned.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorText)
        }
    }

    private func renewBook() {
        isRenewing = true
        Task {
            do {
                try await checkoutService.renewBook(checkout)
            } catch {
                errorText = error.localizedDescription
                showError = true
            }
            isRenewing = false
        }
    }

    private func returnBook() {
        isReturning = true
        Task {
            do {
                try await checkoutService.returnBook(checkout)
            } catch {
                errorText = error.localizedDescription
                showError = true
            }
            isReturning = false
        }
    }
}

#Preview {
    MyBooksView()
        .environmentObject(AppSettings())
        .environmentObject(CheckoutService.shared)
}
