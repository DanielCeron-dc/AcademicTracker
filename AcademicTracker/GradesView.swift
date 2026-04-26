//
//  GradesView.swift
//  AcademicTracker
//
//  Lets the user pick an activity and enter/update grades for every student.
//

import SwiftUI

struct GradesView: View {
    @Environment(CourseStore.self) private var course
    @State private var selectedActivity: Activity?

    var body: some View {
        NavigationStack {
            Group {
                if course.allActivities.isEmpty {
                    ContentUnavailableView(
                        "Sin actividades",
                        systemImage: "checklist",
                        description: Text("Crea una actividad antes de calificar.")
                    )
                } else if course.allStudents.isEmpty {
                    ContentUnavailableView(
                        "Sin estudiantes",
                        systemImage: "person.3",
                        description: Text("Registra estudiantes antes de calificar.")
                    )
                } else {
                    List {
                        Section("Actividad") {
                            Picker("Seleccionar", selection: $selectedActivity) {
                                Text("— Elegir —").tag(Optional<Activity>.none)
                                ForEach(course.allActivities) { a in
                                    Text(a.name).tag(Optional(a))
                                }
                            }
                        }

                        if let activity = selectedActivity {
                            Section("Calificaciones — máx \(activity.maxScore.formatted2())") {
                                ForEach(course.allStudents) { student in
                                    GradeRow(student: student, activity: activity)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calificaciones")
        }
    }
}

private struct GradeRow: View {
    @Environment(CourseStore.self) private var course
    let student: Student
    let activity: Activity

    @State private var scoreText: String = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(student.name).font(.body)
                Text(student.code).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            TextField("0.0", text: $scoreText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
                .onAppear { loadCurrent() }
                .onSubmit { commit() }
                .onChange(of: scoreText) { _, _ in commit() }
        }
    }

    private func loadCurrent() {
        if let g = course.grade(studentId: student.id, activityId: activity.id) {
            scoreText = g.score.formatted2()
        } else {
            scoreText = ""
        }
    }

    private func commit() {
        guard let value = Double(scoreText.replacingOccurrences(of: ",", with: ".")),
              value >= 0,
              value <= activity.maxScore else { return }
        course.recordGrade(studentId: student.id,
                           activityId: activity.id,
                           score: value)
    }
}
