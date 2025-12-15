//
//  ModernSectionHeader.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import SwiftUI

struct ModernSectionHeader: View {
    let title: String
    let subtitle: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Header Variants

struct ModernSectionHeaderWithIcon: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(iconColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CompactSectionHeader: View {
    let title: String
    let subtitle: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionHeaderWithDivider: View {
    let title: String
    let subtitle: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        ModernSectionHeader(
            title: "Standard Header",
            subtitle: "Das ist eine Standard-Sektion mit Titel und Untertitel"
        )
        
        ModernSectionHeaderWithIcon(
            title: "Header mit Icon",
            subtitle: "Sektion mit Icon zur besseren Visualisierung",
            icon: "gear",
            iconColor: .blue
        )
        
        CompactSectionHeader(
            title: "Kompakter Header",
            subtitle: "Kleinere Version für Unterabschnitte"
        )
        
        SectionHeaderWithDivider(
            title: "Header mit Trennlinie",
            subtitle: "Header mit automatischer Trennlinie darunter"
        )
    }
    .padding()
}
