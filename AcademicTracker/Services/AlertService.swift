//
//  AlertService.swift
//  AcademicTracker
//
//  Generates academic alerts (low performance, borderline, missing grades)
//  given course state. Pure — no shared mutable state.
//

import Foundation

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

protocol AlertService {
    func alerts(students: [Student],
                activities: [Activity],
                grades: [Grade],
                grading: GradingService,
                passingThreshold: Double,
                borderlineMargin: Double) -> [AcademicAlert]
}

struct StandardAlertService: AlertService {

    func alerts(students: [Student],
                activities: [Activity],
                grades: [Grade],
                grading: GradingService,
                passingThreshold: Double,
                borderlineMargin: Double) -> [AcademicAlert] {
        var result: [AcademicAlert] = []

        for student in students {
            let avg = grading.weightedAverage(for: student,
                                              activities: activities,
                                              grades: grades)
            let hasAnyGrade = grades.contains { $0.studentId == student.id }

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

            let missing = activities.filter { activity in
                !grades.contains { $0.studentId == student.id && $0.activityId == activity.id }
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
}
