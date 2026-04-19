//
//  ContentView.swift
//  AcademicTracker
//
//  Root tab container. Reads CourseManager from the environment.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var course: CourseManager

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
        .environmentObject(CourseManager())
}
