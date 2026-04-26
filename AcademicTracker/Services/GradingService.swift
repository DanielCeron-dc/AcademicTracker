//
//  GradingService.swift
//  AcademicTracker
//
//  Pure weighted-average calculations. Stateless and easy to test in isolation.
//

import Foundation

protocol GradingService {
    func weightedAverage(for student: Student,
                         activities: [Activity],
                         grades: [Grade]) -> Double

    func courseAverage(students: [Student],
                       activities: [Activity],
                       grades: [Grade]) -> Double
}

struct StandardGradingService: GradingService {

    func weightedAverage(for student: Student,
                         activities: [Activity],
                         grades: [Grade]) -> Double {
        guard !activities.isEmpty else { return 0 }

        let studentGrades = grades.filter { $0.studentId == student.id }
        guard !studentGrades.isEmpty else { return 0 }

        let byActivity = Dictionary(
            uniqueKeysWithValues: studentGrades.map { ($0.activityId, $0) }
        )

        var weightedSum = 0.0
        var weightAccum = 0.0
        for activity in activities {
            weightAccum += activity.weight
            if let g = byActivity[activity.id] {
                let normalized = (g.score / activity.maxScore) * 5.0
                weightedSum += normalized * activity.weight
            }
        }
        return weightAccum > 0 ? weightedSum / weightAccum : 0
    }

    func courseAverage(students: [Student],
                       activities: [Activity],
                       grades: [Grade]) -> Double {
        guard !students.isEmpty else { return 0 }
        let total = students.reduce(0.0) {
            $0 + weightedAverage(for: $1, activities: activities, grades: grades)
        }
        return total / Double(students.count)
    }
}
