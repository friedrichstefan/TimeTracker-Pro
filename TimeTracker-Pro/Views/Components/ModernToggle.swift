//
//  ModernToggle.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import SwiftUI

struct ModernToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Enhanced Toggle Variants

struct ModernToggleWithIcon: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 4)
    }
}

struct ModernToggleCard: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isOn ? Color.blue.opacity(0.1) : Color.primary.opacity(colorScheme == .dark ? 0.05 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isOn ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ModernToggle(
            title: "Standard Toggle",
            subtitle: "Das ist eine normale Toggle-Beschreibung",
            isOn: .constant(true)
        )
        
        ModernToggleWithIcon(
            title: "Toggle mit Icon",
            subtitle: "Toggle mit Icon zur besseren Visualisierung",
            icon: "bell.fill",
            iconColor: .blue,
            isOn: .constant(false)
        )
        
        ModernToggleCard(
            title: "Toggle Karte",
            subtitle: "Diese Toggle hat einen eigenen Kartenhintergrund für bessere Hervorhebung",
            isOn: .constant(true)
        )
    }
    .padding()
}
