//
//  SampleDataProvider.swift
//  AcademicTracker
//
//  Seed data used during development and SwiftUI previews. Not part of the
//  domain model — keeping it isolated lets us spin up alternative seeds (empty,
//  stress-test, fixture) without touching CourseStore.
//

import Foundation

struct SampleDataProvider {
    let courseName: String
    let students: [Student]
    let activities: [Activity]
    let grades: [Grade]

    static let empty = SampleDataProvider(
        courseName: "Curso",
        students: [],
        activities: [],
        grades: []
    )

    static let preview: SampleDataProvider = {
        let s1 = Student(code: "20231001", name: "Ana Martínez",  email: "ana@uni.edu")
        let s2 = Student(code: "20231002", name: "Carlos Pérez",  email: "carlos@uni.edu")
        let s3 = Student(code: "20231003", name: "Daniela Rojas", email: "daniela@uni.edu")
        let s4 = Student(code: "20231004", name: "Felipe Gómez",  email: "felipe@uni.edu")

        let a1 = Activity(name: "Parcial 1", type: .exam,     weight: 0.30)
        let a2 = Activity(name: "Quiz 1",    type: .quiz,     weight: 0.10)
        let a3 = Activity(name: "Proyecto",  type: .project,  weight: 0.40)
        let a4 = Activity(name: "Tarea 1",   type: .homework, weight: 0.20)

        let grades: [Grade] = [
            Grade(studentId: s1.id, activityId: a1.id, score: 4.5),
            Grade(studentId: s1.id, activityId: a2.id, score: 4.8),
            Grade(studentId: s1.id, activityId: a3.id, score: 4.2),
            Grade(studentId: s1.id, activityId: a4.id, score: 5.0),

            Grade(studentId: s2.id, activityId: a1.id, score: 3.2),
            Grade(studentId: s2.id, activityId: a2.id, score: 3.0),
            Grade(studentId: s2.id, activityId: a3.id, score: 3.5),
            Grade(studentId: s2.id, activityId: a4.id, score: 3.8),

            Grade(studentId: s3.id, activityId: a1.id, score: 3.0),
            Grade(studentId: s3.id, activityId: a2.id, score: 3.2),
            Grade(studentId: s3.id, activityId: a3.id, score: 3.1),
            // Daniela is missing a4 → triggers a "missing grade" alert.

            Grade(studentId: s4.id, activityId: a1.id, score: 2.0),
            Grade(studentId: s4.id, activityId: a2.id, score: 1.5),
            Grade(studentId: s4.id, activityId: a3.id, score: 2.5),
            Grade(studentId: s4.id, activityId: a4.id, score: 2.0),
        ]

        return SampleDataProvider(
            courseName: "Programación Orientada a Objetos",
            students: [s1, s2, s3, s4],
            activities: [a1, a2, a3, a4],
            grades: grades
        )
    }()
}
