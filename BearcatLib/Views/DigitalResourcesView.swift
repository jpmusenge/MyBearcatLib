//
//  DigitalResourcesView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/25/26.
//

import Foundation
import SwiftUI

// MARK: - Resources View
struct ResourcesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: LibraryResource.ResourceCategory? = nil
    @State private var searchText = ""

    var filteredResources: [LibraryResource] {
        var results = SampleData.resources

        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return results
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilter

                if filteredResources.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredResources) { resource in
                                if resource.name == "Peer Academic Tutoring" {
                                    NavigationLink {
                                        TutoringRequestView()
                                    } label: {
                                        ResourceCard(resource: resource)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    NavigationLink {
                                        ResourceDetailView(resource: resource)
                                    } label: {
                                        ResourceCard(resource: resource)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Layout.paddingLarge)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search resources...")
            .navigationTitle("Library Resources")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
                }
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                ForEach(SampleData.resourceCategories, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)
            .padding(.vertical, 12)
        }
        .background(Theme.Colors.surface)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.03), radius: 3, x: 0, y: 3)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.4))
            Text("No resources found")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
            Text("Try a different search or category.")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Filter Chip (local to this file)

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? Theme.Colors.textOnPrimary : Theme.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Theme.Colors.primary : Theme.Colors.surfaceSecondary)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Theme.Colors.textSecondary.opacity(0.1), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Resource Card Component
struct ResourceCard: View {
    let resource: LibraryResource

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBackground)
                        .frame(width: 44, height: 44)

                    Image(systemName: resource.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name)
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text(resource.description)
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack {
                Text(resource.availableTo)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Theme.Colors.primary.opacity(0.08))
                    )

                Text(resource.category.rawValue)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Theme.Colors.surfaceSecondary)
                    )

                Spacer()

                if resource.url != nil {
                    HStack(spacing: 4) {
                        Text("Open")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(Theme.Colors.primary)
                } else {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
            }
        }
        .padding(16)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
    }

    private var iconColor: Color {
        switch resource.category {
        case .database:   return Color(hex: "4A6CF7")
        case .journal:    return Color(hex: "10B981")
        case .tutoring:   return Color(hex: "F59E0B")
        case .technology: return Color(hex: "8B5CF6")
        case .other:      return Theme.Colors.primary
        }
    }

    private var iconBackground: Color {
        iconColor.opacity(0.1)
    }
}

// MARK: - Resource Detail View

struct ResourceDetailView: View {
    let resource: LibraryResource
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(categoryColor.opacity(0.1))
                            .frame(width: 56, height: 56)

                        Image(systemName: resource.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(resource.name)
                            .font(Theme.Fonts.title)

                        HStack(spacing: 8) {
                            Text(resource.category.rawValue)
                                .font(Theme.Fonts.caption)
                                .foregroundColor(.secondary)

                            Text("·")
                                .foregroundColor(.secondary)

                            Text(resource.availableTo)
                                .font(Theme.Fonts.caption)
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                }

                Divider()

                // About
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(Theme.Fonts.headline)

                    Text(resource.description)
                        .font(Theme.Fonts.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                // How to Access
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to Access")
                        .font(Theme.Fonts.headline)

                    Text(accessInstructions)
                        .font(Theme.Fonts.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                // Open button
                if let urlString = resource.url, let url = URL(string: urlString) {
                    Button {
                        openURL(url)
                    } label: {
                        HStack {
                            Text("Open \(resource.name)")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(Theme.Fonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.primary)
                        .cornerRadius(Theme.Layout.cornerRadius)
                    }
                }

                // Tips
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips")
                        .font(Theme.Fonts.headline)

                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.accent)
                                .padding(.top, 2)
                            Text(tip)
                                .font(Theme.Fonts.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(Theme.Layout.paddingLarge)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle(resource.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var categoryColor: Color {
        switch resource.category {
        case .database:   return Color(hex: "4A6CF7")
        case .journal:    return Color(hex: "10B981")
        case .tutoring:   return Color(hex: "F59E0B")
        case .technology: return Color(hex: "8B5CF6")
        case .other:      return Theme.Colors.primary
        }
    }

    private var accessInstructions: String {
        switch resource.name {
        case "JSTOR":
            return "Access JSTOR through your Rust College credentials. On campus, you're automatically authenticated. Off campus, log in with your @rustcollege.edu email when prompted."
        case "EBSCO Academic Search":
            return "Available on and off campus. Use your Rust College library credentials to sign in. Ask at the circulation desk if you need your login information."
        case "ProQuest":
            return "Access ProQuest from the library website or directly. Authenticate with your Rust College email. Great for finding dissertations and thesis papers."
        case "IEEE Xplore":
            return "Available to CS and Engineering students. Access through the campus network or VPN. Contact the library for off-campus access credentials."
        case "MAGNOLIA":
            return "MAGNOLIA databases are free for all Mississippi residents. Access through the library's website using the location ID provided by Leontyne Price Library. Ask at the circulation desk for the access code."
        case "Google Scholar":
            return "Google Scholar is freely available. For full-text access to paywalled articles, set up your Rust College library link in Google Scholar settings under 'Library links.'"
        case "PubMed":
            return "PubMed is freely available to everyone. For full-text access, look for the 'Free full text' filter or use your Rust College library link for paywalled journals."
        case "Writing Center":
            return "Visit the Writing Center on the 1st floor of Leontyne Price Library. Walk-ins are welcome, or schedule an appointment at the circulation desk. Bring your assignment prompt and any drafts."
        case "Charger Lending":
            return "Visit the front desk at Leontyne Price Library with your student ID. Chargers are for in-library use only and must be returned before closing."
        case "Scanner & Copier":
            return "The self-service station is on the 1st floor near the entrance. Scanning is free — just bring a USB drive or email the scan to yourself. Copies are $0.10 per page."
        default:
            return "Visit Leontyne Price Library or contact the circulation desk at 662-252-8000 Ext. 4100 for access information."
        }
    }

    private var tips: [String] {
        switch resource.category {
        case .database:
            return [
                "Use Boolean operators (AND, OR, NOT) to refine your search results.",
                "Check if the database offers citation export to tools like Zotero or EndNote.",
                "Save your searches to revisit them later when working on long research projects."
            ]
        case .journal:
            return [
                "Use filters to narrow results by date, peer-reviewed status, and subject area.",
                "Look for the 'Cite' button to quickly generate citations in APA, MLA, or Chicago format.",
                "Set up alerts for new articles in your research area."
            ]
        case .tutoring:
            return [
                "Bring your specific questions or problem sets to make the most of your session.",
                "Tutoring is most effective when you've already attempted the work first.",
                "Don't wait until the night before an exam — schedule sessions early in the week."
            ]
        case .technology:
            return [
                "Have your student ID ready when requesting equipment.",
                "Return borrowed items on time so other students can use them.",
                "Report any issues with equipment to library staff immediately."
            ]
        case .other:
            return ["Contact the library for more information about this resource."]
        }
    }
}

// MARK: - Preview

#Preview {
    ResourcesView()
}
