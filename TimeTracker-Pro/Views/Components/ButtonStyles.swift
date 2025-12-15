//
//  ButtonStyles.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import SwiftUI

// MARK: - Export Button Styles

struct ExportButtonStyle: ButtonStyle {
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color, in: RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(
                color: color.opacity(colorScheme == .dark ? 0.4 : 0.2),
                radius: colorScheme == .dark ? 3 : 2,
                x: 0,
                y: 1
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Timer Button Styles

struct StartButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 60, height: 28)
            .background(color, in: RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct StopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 60, height: 28)
            .background(.red, in: RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ResetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(.secondary)
            .frame(width: 60, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.1) : Color.clear)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Navigation Button Styles

struct DateNavigationButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? .blue : .primary)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.blue.opacity(0.1) : Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                radius: colorScheme == .dark ? 3 : 1,
                x: 0,
                y: 1
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AnalyseDateNavigationButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? .blue : .primary)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.blue.opacity(0.1) : Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.2 : 0.05),
                radius: colorScheme == .dark ? 2 : 1,
                x: 0,
                y: 1
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TodayButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.1) : Color.clear)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(
                color: .blue.opacity(colorScheme == .dark ? 0.4 : 0.2),
                radius: colorScheme == .dark ? 2 : 1,
                x: 0,
                y: 1
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Action Button Styles

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.red.opacity(0.1) : Color.clear)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ClearButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color.red.opacity(0.1) : Color.clear)
                    .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(
                color: .red.opacity(colorScheme == .dark ? 0.4 : 0.2),
                radius: colorScheme == .dark ? 2 : 1,
                x: 0,
                y: 1
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Analyse Button Styles

struct EnableTrackingButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.blue, in: RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(
                color: .blue.opacity(colorScheme == .dark ? 0.6 : 0.3),
                radius: colorScheme == .dark ? 4 : 2,
                x: 0,
                y: 1
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            Button("CSV Export") { }
                .buttonStyle(ExportButtonStyle(color: .blue))
            
            Button("JSON Export") { }
                .buttonStyle(ExportButtonStyle(color: .green))
        }
        
        HStack(spacing: 12) {
            Button("Start") { }
                .buttonStyle(StartButtonStyle(color: .blue))
            
            Button("Stop") { }
                .buttonStyle(StopButtonStyle())
            
            Button("Reset") { }
                .buttonStyle(ResetButtonStyle())
        }
        
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(DateNavigationButtonStyle())
            
            Button("Heute") { }
                .buttonStyle(TodayButtonStyle())
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(DateNavigationButtonStyle())
        }
        
        HStack(spacing: 12) {
            Button("Löschen") { }
                .buttonStyle(DangerButtonStyle())
            
            Button("Tag löschen") { }
                .buttonStyle(ClearButtonStyle())
        }
        
        Button("App-Tracking aktivieren") { }
            .buttonStyle(EnableTrackingButtonStyle())
    }
    .padding()
}
