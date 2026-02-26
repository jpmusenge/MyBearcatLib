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
                // Category filter
                categoryFilter
                
                // Resources list
                if filteredResources.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredResources) { resource in
                                ResourceCard(resource: resource)
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
                // All chip
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
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBackground)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: resource.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Text content
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
            
            // Bottom row: availability tag + link indicator
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
                }
            }
        }
        .padding(16)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
    }
    
    // Color coding by category
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

// MARK: - Preview

#Preview {
    ResourcesView()
}
