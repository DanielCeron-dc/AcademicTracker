//
//  CourseManager.swift
//  AcademicTracker
//
//  Core business logic. Holds all course state and exposes:
//   - CRUD for students, activities, grades
//   - Weighted average calculations
//   - Low-performance detection
//   - Academic alerts
//   - Course-level reports
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class CourseManager: ObservableObject {

    // MARK: - Published state
    @Published var courseName: String = "Curso de Ejemplo"
    @Published var students: [Student] = []
    @Published var activities: [Activity] = []
    @Published var grades: [Grade] = []

    /// Minimum passing average. Default 3.0 (Colombian 0–5 scale).
    @Published var passingThreshold: Double = 3.0

    /// Margin used to flag "borderline" students (close to failing).
    @Published var borderlineMargin: Double = 0.3

    // MARK: - Init
    init(seedSampleData: Bool = true) {
        if seedSampleData { loadSampleData() }
    }

    // MARK: - Student CRUD
    func addStudent(code: String, name: String, email: String) {
        students.append(Student(code: code, name: name, email: email))
    }

    func removeStudent(_ student: Student) {
        students.removeAll { $0.id == student.id }
        // cascade: remove the student's grades too
        grades.removeAll { $0.studentId == student.id }
    }

    // MARK: - Activity CRUD
    func addActivity(name: String,
                     type: ActivityType,
                     weight: Double,
                     maxScore: Double = 5.0,
                     date: Date = Date()) {
        activities.append(Activity(name: name,
                                   type: type,
                                   weight: weight,
                                   maxScore: maxScore,
                                   date: date))
    }

    func removeActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        grades.removeAll { $0.activityId == activity.id }
    }

    /// Sum of all activity weights. Should normally be 1.0 (100%).
    var totalWeight: Double {
        activities.reduce(0) { $0 + $1.weight }
    }

    // MARK: - Grade CRUD
    /// Records a grade. If one already exists for that (student, activity) pair, it's updated.
    func recordGrade(studentId: UUID, activityId: UUID, score: Double) {
        if let i = grades.firstIndex(where: {
            $0.studentId == studentId && $0.activityId == activityId
        }) {
            grades[i].score = score
            grades[i].date = Date()
        } else {
            grades.append(Grade(studentId: studentId,
                                activityId: activityId,
                                score: score))
        }
    }

    func grade(studentId: UUID, activityId: UUID) -> Grade? {
        grades.first { $0.studentId == studentId && $0.activityId == activityId }
    }

    // MARK: - Performance calculations

    /// Weighted average for one student, normalized to a 0–5 scale.
    /// Missing grades count as 0 only if the student has at least one grade.
    /// Returns 0 if the student has no grades at all.
    func weightedAverage(for student: Student) -> Double {
        guard !activities.isEmpty else { return 0 }
        let studentGrades = grades.filter { $0.studentId == student.id }
        guard !studentGrades.isEmpty else { return 0 }

        var weightedSum: Double = 0
        var weightAccum: Double = 0

        for activity in activities {
            weightAccum += activity.weight
            if let g = grade(studentId: student.id, activityId: activity.id) {
                let normalized = (g.score / activity.maxScore) * 5.0
                weightedSum += normalized * activity.weight
            }
            // missing grade contributes 0 to weightedSum but its weight still counts
        }

        return weightAccum > 0 ? weightedSum / weightAccum : 0
    }

    /// Average of all student averages.
    var courseAverage: Double {
        guard !students.isEmpty else { return 0 }
        let total = students.reduce(0.0) { $0 + weightedAverage(for: $1) }
        return total / Double(students.count)
    }

    /// Students whose weighted average is below the passing threshold.
    var lowPerformanceStudents: [Student] {
        students.filter { weightedAverage(for: $0) < passingThreshold }
    }

    /// Students who haven't been graded on any activity yet.
    var ungradedStudents: [Student] {
        students.filter { s in !grades.contains { $0.studentId == s.id } }
    }

    // MARK: - Academic alerts

    enum AlertSeverity {
        case info, warning, critical
    }

    struct AcademicAlert: Identifiable {
        let id = UUID()
        let student: Student
        let severity: AlertSeverity
        let title: String
        let message: String
    }

    var alerts: [AcademicAlert] {
        var result: [AcademicAlert] = []

        for student in students {
            let avg = weightedAverage(for: student)
            let hasAnyGrade = grades.contains { $0.studentId == student.id }

            // Low performance (only if student actually has grades)
            if hasAnyGrade && avg < passingThreshold {
                result.append(AcademicAlert(
                    student: student,
                    severity: .critical,
                    title: "Bajo rendimiento",
                    message: "Promedio \(avg.formatted2()) por debajo del mínimo (\(passingThreshold.formatted2()))."
                ))
            } else if hasAnyGrade && avg < passingThreshold + borderlineMargin {
                result.append(AcademicAlert(
                    student: student,
                    severity: .warning,
                    title: "En el límite",
                    message: "Promedio \(avg.formatted2()) cerca del mínimo aprobatorio."
                ))
            }

            // Missing grades
            let missing = activities.filter {
                grade(studentId: student.id, activityId: $0.id) == nil
            }
            if !activities.isEmpty && !missing.isEmpty {
                result.append(AcademicAlert(
                    student: student,
                    severity: missing.count == activities.count ? .critical : .info,
                    title: "Calificaciones pendientes",
                    message: "Faltan \(missing.count) de \(activities.count) actividades."
                ))
            }
        }
        return result
    }

    // MARK: - Reports

    struct CourseReport {
        let totalStudents: Int
        let totalActivities: Int
        let totalWeight: Double
        let courseAverage: Double
        let passingCount: Int
        let failingCount: Int
        let highestAverage: Double
        let lowestAverage: Double
        let topStudent: Student?
        let bottomStudent: Student?
    }

    func generateReport() -> CourseReport {
        let averages = students.map { weightedAverage(for: $0) }
        let passing = students.filter {
            weightedAverage(for: $0) >= passingThreshold
        }.count
        let top = students.max { weightedAverage(for: $0) < weightedAverage(for: $1) }
        let bot = students.min { weightedAverage(for: $0) < weightedAverage(for: $1) }

        return CourseReport(
            totalStudents: students.count,
            totalActivities: activities.count,
            totalWeight: totalWeight,
            courseAverage: courseAverage,
            passingCount: passing,
            failingCount: students.count - passing,
            highestAverage: averages.max() ?? 0,
            lowestAverage: averages.min() ?? 0,
            topStudent: top,
            bottomStudent: bot
        )
    }

    // MARK: - Sample data
    private func loadSampleData() {
        courseName = "Programación Orientada a Objetos"

        let s1 = Student(code: "20231001", name: "Ana Martínez",  email: "ana@uni.edu")
        let s2 = Student(code: "20231002", name: "Carlos Pérez",  email: "carlos@uni.edu")
        let s3 = Student(code: "20231003", name: "Daniela Rojas", email: "daniela@uni.edu")
        let s4 = Student(code: "20231004", name: "Felipe Gómez",  email: "felipe@uni.edu")
        students = [s1, s2, s3, s4]

        let a1 = Activity(name: "Parcial 1", type: .exam,    weight: 0.30)
        let a2 = Activity(name: "Quiz 1",    type: .quiz,    weight: 0.10)
        let a3 = Activity(name: "Proyecto",  type: .project, weight: 0.40)
        let a4 = Activity(name: "Tarea 1",   type: .homework, weight: 0.20)
        activities = [a1, a2, a3, a4]

        // seed grades — Felipe is intentionally low-performing
        recordGrade(studentId: s1.id, activityId: a1.id, score: 4.5)
        recordGrade(studentId: s1.id, activityId: a2.id, score: 4.8)
        recordGrade(studentId: s1.id, activityId: a3.id, score: 4.2)
        recordGrade(studentId: s1.id, activityId: a4.id, score: 5.0)

        recordGrade(studentId: s2.id, activityId: a1.id, score: 3.2)
        recordGrade(studentId: s2.id, activityId: a2.id, score: 3.0)
        recordGrade(studentId: s2.id, activityId: a3.id, score: 3.5)
        recordGrade(studentId: s2.id, activityId: a4.id, score: 3.8)

        recordGrade(studentId: s3.id, activityId: a1.id, score: 3.0)
        recordGrade(studentId: s3.id, activityId: a2.id, score: 3.2)
        recordGrade(studentId: s3.id, activityId: a3.id, score: 3.1)
        // missing a4 → triggers a "missing grade" alert

        recordGrade(studentId: s4.id, activityId: a1.id, score: 2.0)
        recordGrade(studentId: s4.id, activityId: a2.id, score: 1.5)
        recordGrade(studentId: s4.id, activityId: a3.id, score: 2.5)
        recordGrade(studentId: s4.id, activityId: a4.id, score: 2.0)
    }
}

// MARK: - Helper
extension Double {
    func formatted2() -> String { String(format: "%.2f", self) }
}
