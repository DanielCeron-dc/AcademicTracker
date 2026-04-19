//
//  StudentsView.swift
//  AcademicTracker
//

import SwiftUI

struct StudentsView: View {
    @EnvironmentObject var course: CourseManager
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(course.students) { student in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(student.name).font(.headline)
                            Text(student.code).font(.caption).foregroundStyle(.secondary)
                            Text(student.email).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(course.weightedAverage(for: student).formatted2())
                            .font(.title3.monospacedDigit().bold())
                            .foregroundStyle(
                                course.weightedAverage(for: student) >= course.passingThreshold
                                ? .green : .red
                            )
                    }
                }
                .onDelete { idx in
                    idx.map { course.students[$0] }.forEach(course.removeStudent)
                }
            }
            .navigationTitle("Estudiantes")
            .toolbar {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddStudentSheet()
            }
            .overlay {
                if course.students.isEmpty {
                    ContentUnavailableView(
                        "Sin estudiantes",
                        systemImage: "person.3",
                        description: Text("Toca + para registrar el primero.")
                    )
                }
            }
        }
    }
}

private struct AddStudentSheet: View {
    @EnvironmentObject var course: CourseManager
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Código", text: $code)
                    .keyboardType(.numberPad)
                TextField("Nombre completo", text: $name)
                TextField("Correo", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            .navigationTitle("Nuevo estudiante")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        course.addStudent(code: code, name: name, email: email)
                        dismiss()
                    }
                    .disabled(name.isEmpty || code.isEmpty)
                }
            }
        }
    }
}
