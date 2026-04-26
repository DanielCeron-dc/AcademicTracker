//
//  ReportService.swift
//  AcademicTracker
//
//  Builds an aggregate snapshot of the course (totals, extremes, top/bottom).
//

import Foundation

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

protocol ReportService {
    func generate(students: [Student],
                  activities: [Activity],
                  grades: [Grade],
                  grading: GradingService,
                  passingThreshold: Double) -> CourseReport
}

struct StandardReportService: ReportService {

    func generate(students: [Student],
                  activities: [Activity],
                  grades: [Grade],
                  grading: GradingService,
                  passingThreshold: Double) -> CourseReport {
        let averages = students.map {
            grading.weightedAverage(for: $0, activities: activities, grades: grades)
        }
        let passing = zip(students, averages).filter { $0.1 >= passingThreshold }.count
        let topIndex = averages.indices.max { averages[$0] < averages[$1] }
        let botIndex = averages.indices.min { averages[$0] < averages[$1] }
        let courseAvg = students.isEmpty ? 0 : averages.reduce(0, +) / Double(students.count)

        return CourseReport(
            totalStudents: students.count,
            totalActivities: activities.count,
            totalWeight: activities.reduce(0) { $0 + $1.weight },
            courseAverage: courseAvg,
            passingCount: passing,
            failingCount: students.count - passing,
            highestAverage: averages.max() ?? 0,
            lowestAverage: averages.min() ?? 0,
            topStudent: topIndex.map { students[$0] },
            bottomStudent: botIndex.map { students[$0] }
        )
    }
}
