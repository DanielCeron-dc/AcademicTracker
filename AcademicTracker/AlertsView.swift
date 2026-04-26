//
//  AlertsView.swift
//  AcademicTracker
//

import SwiftUI

struct AlertsView: View {
    @Environment(CourseStore.self) private var course

    var body: some View {
        NavigationStack {
            let alerts = course.alerts
            let critical = alerts.filter { $0.severity == .critical }
            let warning  = alerts.filter { $0.severity == .warning }
            let info     = alerts.filter { $0.severity == .info }

            List {
                if !critical.isEmpty {
                    Section("Críticas") {
                        ForEach(critical) { AlertRow(alert: $0) }
                    }
                }
                if !warning.isEmpty {
                    Section("Advertencias") {
                        ForEach(warning) { AlertRow(alert: $0) }
                    }
                }
                if !info.isEmpty {
                    Section("Informativas") {
                        ForEach(info) { AlertRow(alert: $0) }
                    }
                }
            }
            .navigationTitle("Alertas")
            .overlay {
                if alerts.isEmpty {
                    ContentUnavailableView(
                        "Sin alertas",
                        systemImage: "checkmark.seal.fill",
                        description: Text("Todos los estudiantes están al día.")
                    )
                }
            }
        }
    }
}

private struct AlertRow: View {
    let alert: AcademicAlert

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.student.name).font(.headline)
                Text(alert.title).font(.subheadline).foregroundStyle(color)
                Text(alert.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var icon: String {
        switch alert.severity {
        case .critical: return "exclamationmark.octagon.fill"
        case .warning:  return "exclamationmark.triangle.fill"
        case .info:     return "info.circle.fill"
        }
    }

    private var color: Color {
        switch alert.severity {
        case .critical: return .red
        case .warning:  return .orange
        case .info:     return .blue
        }
    }
}
