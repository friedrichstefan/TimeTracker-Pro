//
//  ModernCard.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import SwiftUI

struct ModernCard<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 0.5)
        )
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
            radius: colorScheme == .dark ? 8 : 4,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Card Header Component

struct CardHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ModernCard {
            CardHeader(
                title: "Beispiel Karte",
                subtitle: "Das ist eine Beispiel-Beschreibung",
                icon: "clock.badge.checkmark",
                iconColor: .blue
            )
        }
        
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Inhalt")
                    .font(.headline)
                
                Text("Hier steht der Karteninhalt mit verschiedenen Elementen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}
