//
//  AcademicTrackerApp.swift
//  AcademicTracker
//
//  Entry point. Hosts CourseManager as a single source of truth via @StateObject
//  and injects it into the environment for all child views.
//

import SwiftUI

@main
struct AcademicTrackerApp: App {
    @StateObject private var course = CourseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(course)
        }
    }
}
