//
//  ActivitiesView.swift
//  AcademicTracker
//

import SwiftUI

struct ActivitiesView: View {
    @Environment(CourseStore.self) private var course
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(course.allActivities) { a in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(a.name).font(.headline)
                                Text(a.type.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(Int(a.weight * 100))%")
                                .font(.title3.monospacedDigit().bold())
                                .foregroundStyle(.blue)
                        }
                    }
                    .onDelete { idx in
                        idx.map { course.allActivities[$0] }.forEach(course.removeActivity)
                    }
                } footer: {
                    HStack {
                        Text("Suma de pesos:")
                        Spacer()
                        Text("\(Int(course.totalWeight * 100))%")
                            .foregroundStyle(
                                abs(course.totalWeight - 1.0) < 0.001 ? .green : .orange
                            )
                            .bold()
                    }
                }
            }
            .navigationTitle("Actividades")
            .toolbar {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddActivitySheet()
            }
            .overlay {
                if course.allActivities.isEmpty {
                    ContentUnavailableView(
                        "Sin actividades",
                        systemImage: "doc.text",
                        description: Text("Registra exámenes, quices, tareas o proyectos.")
                    )
                }
            }
        }
    }
}

private struct AddActivitySheet: View {
    @Environment(CourseStore.self) private var course
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: ActivityType = .exam
    @State private var weightPct: Double = 20    // percent (0–100)
    @State private var maxScore: Double = 5.0
    @State private var date: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $name)

                Picker("Tipo", selection: $type) {
                    ForEach(ActivityType.allCases) { Text($0.rawValue).tag($0) }
                }

                Section("Peso (\(Int(weightPct))%)") {
                    Slider(value: $weightPct, in: 1...100, step: 1)
                }

                Stepper("Nota máxima: \(maxScore.formatted2())",
                        value: $maxScore, in: 1...10, step: 0.5)

                DatePicker("Fecha", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Nueva actividad")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        course.addActivity(
                            name: name,
                            type: type,
                            weight: weightPct / 100.0,
                            maxScore: maxScore,
                            date: date
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
