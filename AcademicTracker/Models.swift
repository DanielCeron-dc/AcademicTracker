//
//  Models.swift
//  AcademicTracker
//
//  Core data models. All Codable so they can be persisted with JSONEncoder later.
//

import Foundation

// MARK: - Student

struct Student: Identifiable, Codable, Hashable {
    let id: UUID
    var code: String     // student code / código institucional
    var name: String
    var email: String

    init(id: UUID = UUID(), code: String, name: String, email: String) {
        self.id = id
        self.code = code
        self.name = name
        self.email = email
    }
}

// MARK: - Activity

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case exam        = "Examen"
    case quiz        = "Quiz"
    case homework    = "Tarea"
    case project     = "Proyecto"
    case participation = "Participación"

    var id: String { rawValue }
}

struct Activity: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: ActivityType
    var weight: Double      // percentage weight, e.g. 0.30 for 30%
    var maxScore: Double    // typically 5.0 in Colombian system
    var date: Date

    init(id: UUID = UUID(),
         name: String,
         type: ActivityType,
         weight: Double,
         maxScore: Double = 5.0,
         date: Date = Date()) {
        self.id = id
        self.name = name
        self.type = type
        self.weight = weight
        self.maxScore = maxScore
        self.date = date
    }
}

// MARK: - Grade

struct Grade: Identifiable, Codable, Hashable {
    let id: UUID
    var studentId: UUID
    var activityId: UUID
    var score: Double       // raw score (0...maxScore of the activity)
    var date: Date

    init(id: UUID = UUID(),
         studentId: UUID,
         activityId: UUID,
         score: Double,
         date: Date = Date()) {
        self.id = id
        self.studentId = studentId
        self.activityId = activityId
        self.score = score
        self.date = date
    }
}
