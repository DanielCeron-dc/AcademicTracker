//
//  ReportsView.swift
//  AcademicTracker
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var course: CourseManager

    var body: some View {
        NavigationStack {
            let report = course.generateReport()

            List {
                Section("Resumen general") {
                    StatRow(label: "Estudiantes",  value: "\(report.totalStudents)")
                    StatRow(label: "Actividades", value: "\(report.totalActivities)")
                    StatRow(label: "Suma de pesos",
                            value: "\(Int(report.totalWeight * 100))%")
                    StatRow(label: "Promedio del curso",
                            value: report.courseAverage.formatted2(),
                            color: report.courseAverage >= course.passingThreshold ? .green : .red)
                }

                Section("Aprobación") {
                    StatRow(label: "Aprobados",
                            value: "\(report.passingCount)",
                            color: .green)
                    StatRow(label: "Reprobados",
                            value: "\(report.failingCount)",
                            color: .red)
                }

                Section("Extremos") {
                    StatRow(label: "Mejor promedio",
                            value: report.highestAverage.formatted2())
                    if let top = report.topStudent {
                        Text("🏆 \(top.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    StatRow(label: "Peor promedio",
                            value: report.lowestAverage.formatted2())
                    if let bot = report.bottomStudent {
                        Text("⚠️ \(bot.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Listado completo") {
                    ForEach(course.students.sorted { a, b in
                        course.weightedAverage(for: a) > course.weightedAverage(for: b)
                    }) { student in
                        HStack {
                            Text(student.name)
                            Spacer()
                            Text(course.weightedAverage(for: student).formatted2())
                                .monospacedDigit()
                                .bold()
                                .foregroundStyle(
                                    course.weightedAverage(for: student) >= course.passingThreshold
                                    ? .green : .red
                                )
                        }
                    }
                }
            }
            .navigationTitle("Reportes")
        }
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).bold().foregroundStyle(color)
        }
    }
}
