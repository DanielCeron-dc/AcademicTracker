//
//  InMemoryRepository.swift
//  AcademicTracker
//
//  Default in-memory `Repository`. Uses Swift's Observation framework so any
//  SwiftUI view that reads `items` is automatically re-rendered on mutation.
//  State lives only for the lifetime of the process.
//

import Foundation
import Observation

@MainActor
@Observable
final class InMemoryRepository<Entity: Identifiable>: Repository {
    private(set) var items: [Entity]

    init(items: [Entity] = []) {
        self.items = items
    }

    func add(_ item: Entity) {
        items.append(item)
    }

    func update(_ item: Entity) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[i] = item
    }

    func remove(id: Entity.ID) {
        items.removeAll { $0.id == id }
    }

    func find(id: Entity.ID) -> Entity? {
        items.first { $0.id == id }
    }
}
