//
//  ContentView.swift
//  AcademicTracker
//
//  Root tab container. Reads `CourseStore` from the environment.
//

import SwiftUI

struct ContentView: View {
    @Environment(CourseStore.self) private var course

    var body: some View {
        TabView {
            StudentsView()
                .tabItem { Label("Estudiantes", systemImage: "person.3.fill") }

            ActivitiesView()
                .tabItem { Label("Actividades", systemImage: "doc.text.fill") }

            GradesView()
                .tabItem { Label("Calificaciones", systemImage: "checklist") }

            ReportsView()
                .tabItem { Label("Reportes", systemImage: "chart.bar.fill") }

            AlertsView()
                .tabItem { Label("Alertas", systemImage: "bell.badge.fill") }
        }
    }
}

#Preview {
    ContentView()
        .environment(CourseStore())
}
