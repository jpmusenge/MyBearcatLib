//
//  DigitalResourcesView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/25/26.
//

import Foundation

import SwiftUI

struct DigitalResourcesView: View {
    let categories = ["Databases", "eBooks", "Services"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Digital Resources")
                        .font(Theme.Fonts.largeTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("Access journals, databases, and campus tutoring services directly from your device.")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(.horizontal, Theme.Layout.paddingLarge)
                .padding(.top, 16)
                
                // Grouped Content
                ForEach(categories, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category)
                            .font(Theme.Fonts.title2)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .padding(.horizontal, Theme.Layout.paddingLarge)
                        
                        VStack(spacing: 12) {
                            ForEach(SampleData.resources.filter { $0.category == category }) { resource in
                                ResourceRow(resource: resource)
                            }
                        }
                        .padding(.horizontal, Theme.Layout.paddingLarge)
                    }
                }
                
                Spacer().frame(height: 40)
            }
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResourceRow: View {
    let resource: Resource
    
    var body: some View {
        Button(action: {
            // this would open a Safari view
            print("Opening \(resource.url)")
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.Colors.primary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: resource.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name)
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(resource.description)
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            }
            .padding(12)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        DigitalResourcesView()
    }
}
