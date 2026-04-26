//
//  AcademicTrackerApp.swift
//  AcademicTracker
//
//  Entry point. Owns the single `CourseStore` for the app's lifetime and
//  injects it into the SwiftUI environment using the modern Observation API.
//

import SwiftUI

@main
struct AcademicTrackerApp: App {
    @State private var course = CourseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(course)
        }
    }
}
