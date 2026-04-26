//
//  CourseStore.swift
//  AcademicTracker
//
//  Composition root. Owns one `Repository` per entity and a set of pure
//  domain services, then exposes a single, view-friendly API. Replaces
//  the former monolithic `CourseManager`.
//
//  Why this shape:
//   - Repositories hide *where* data lives (in-memory today, swappable
//     for a JSON-on-disk or remote backend tomorrow) without rewriting views.
//   - Services hide *how* derived state is computed and stay stateless,
//     which keeps them trivially unit-testable.
//   - This class is the only `@Observable` type the views see, so the
//     environment stays a single object.
//

import Foundation
import Observation

@MainActor
@Observable
final class CourseStore {

    // MARK: - Configuration
    var courseName: String
    var passingThreshold: Double
    var borderlineMargin: Double

    // MARK: - State (per-entity repositories)
    @ObservationIgnored let students: any Repository<Student>
    @ObservationIgnored let activities: any Repository<Activity>
    @ObservationIgnored let grades: any Repository<Grade>

    // MARK: - Services (pure)
    @ObservationIgnored private let grading: GradingService
    @ObservationIgnored private let alertService: AlertService
    @ObservationIgnored private let reportService: ReportService

    // MARK: - Init / dependency injection
    //
    // The full initializer requires every collaborator to be supplied
    // explicitly — handy for tests that want to swap an in-memory repo for a
    // disk-backed one, or replace `StandardGradingService` with a stub.
    init(
        students: any Repository<Student>,
        activities: any Repository<Activity>,
        grades: any Repository<Grade>,
        grading: GradingService,
        alertService: AlertService,
        reportService: ReportService,
        seed: SampleDataProvider?,
        passingThreshold: Double,
        borderlineMargin: Double
    ) {
        self.students = students
        self.activities = activities
        self.grades = grades
        self.grading = grading
        self.alertService = alertService
        self.reportService = reportService
        self.passingThreshold = passingThreshold
        self.borderlineMargin = borderlineMargin
        self.courseName = seed?.courseName ?? "Curso"

        if let seed {
            seed.students.forEach(students.add)
            seed.activities.forEach(activities.add)
            seed.grades.forEach(grades.add)
        }
    }

    /// Convenience initializer that wires up the standard in-memory + standard
    /// service stack. The defaults touch `@MainActor` types, which is why they
    /// live here (in a `@MainActor`-isolated body) instead of as default
    /// parameter values on the designated init.
    convenience init(seed: SampleDataProvider? = .preview,
                     passingThreshold: Double = 3.0,
                     borderlineMargin: Double = 0.3) {
        self.init(
            students: InMemoryRepository<Student>(),
            activities: InMemoryRepository<Activity>(),
            grades: InMemoryRepository<Grade>(),
            grading: StandardGradingService(),
            alertService: StandardAlertService(),
            reportService: StandardReportService(),
            seed: seed,
            passingThreshold: passingThreshold,
            borderlineMargin: borderlineMargin
        )
    }

    // MARK: - Read projections
    // Views read these instead of touching repositories directly. Each access
    // hits the underlying `@Observable` repository, so SwiftUI tracks changes.
    var allStudents: [Student]   { students.items }
    var allActivities: [Activity] { activities.items }
    var allGrades: [Grade]       { grades.items }

    // MARK: - Student commands
    func addStudent(code: String, name: String, email: String) {
        students.add(Student(code: code, name: name, email: email))
    }

    func removeStudent(_ student: Student) {
        students.remove(id: student.id)
        // Cascade: drop the student's grades.
        grades.items
            .filter { $0.studentId == student.id }
            .forEach { grades.remove(id: $0.id) }
    }

    // MARK: - Activity commands
    func addActivity(name: String,
                     type: ActivityType,
                     weight: Double,
                     maxScore: Double = 5.0,
                     date: Date = Date()) {
        activities.add(Activity(name: name,
                                type: type,
                                weight: weight,
                                maxScore: maxScore,
                                date: date))
    }

    func removeActivity(_ activity: Activity) {
        activities.remove(id: activity.id)
        grades.items
            .filter { $0.activityId == activity.id }
            .forEach { grades.remove(id: $0.id) }
    }

    var totalWeight: Double {
        allActivities.reduce(0) { $0 + $1.weight }
    }

    // MARK: - Grade commands
    /// Records a grade. If one already exists for that (student, activity) pair, it's updated.
    func recordGrade(studentId: UUID, activityId: UUID, score: Double) {
        if let existing = grades.items.first(where: {
            $0.studentId == studentId && $0.activityId == activityId
        }) {
            var updated = existing
            updated.score = score
            updated.date = Date()
            grades.update(updated)
        } else {
            grades.add(Grade(studentId: studentId,
                             activityId: activityId,
                             score: score))
        }
    }

    func grade(studentId: UUID, activityId: UUID) -> Grade? {
        grades.items.first { $0.studentId == studentId && $0.activityId == activityId }
    }

    // MARK: - Derived state (delegated to services)
    func weightedAverage(for student: Student) -> Double {
        grading.weightedAverage(for: student,
                                activities: allActivities,
                                grades: allGrades)
    }

    var courseAverage: Double {
        grading.courseAverage(students: allStudents,
                              activities: allActivities,
                              grades: allGrades)
    }

    var lowPerformanceStudents: [Student] {
        allStudents.filter { weightedAverage(for: $0) < passingThreshold }
    }

    var ungradedStudents: [Student] {
        allStudents.filter { s in !allGrades.contains { $0.studentId == s.id } }
    }

    var alerts: [AcademicAlert] {
        alertService.alerts(students: allStudents,
                            activities: allActivities,
                            grades: allGrades,
                            grading: grading,
                            passingThreshold: passingThreshold,
                            borderlineMargin: borderlineMargin)
    }

    func generateReport() -> CourseReport {
        reportService.generate(students: allStudents,
                               activities: allActivities,
                               grades: allGrades,
                               grading: grading,
                               passingThreshold: passingThreshold)
    }
}
