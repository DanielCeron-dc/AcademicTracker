//
//  Repository.swift
//  AcademicTracker
//
//  Generic CRUD abstraction over a collection of identifiable entities.
//  Today the only implementation is in-memory, but the protocol leaves room
//  for a disk- or network-backed store without touching call sites.
//

import Foundation

protocol Repository<Entity>: AnyObject {
    associatedtype Entity: Identifiable

    var items: [Entity] { get }

    func add(_ item: Entity)
    func update(_ item: Entity)
    func remove(id: Entity.ID)
    func find(id: Entity.ID) -> Entity?
}

extension Repository {
    func remove(_ item: Entity) { remove(id: item.id) }

    func upsert(_ item: Entity) {
        if find(id: item.id) == nil { add(item) } else { update(item) }
    }
}
