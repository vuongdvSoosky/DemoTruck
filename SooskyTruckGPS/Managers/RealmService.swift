//
//  RealmService.swift
//  Base_MVVM_Combine
//
//  Created by Trịnh Xuân Minh on 02/02/2024.
//

import Foundation
import RealmSwift

final class RealmService {
  static let shared = RealmService()
  
  private let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
}

extension RealmService {
  func fetch<T: Object>(ofType type: T.Type) -> [T] {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      let results = realm.objects(type.self)
      return Array(results)
    } catch {
      return []
    }
  }
  
  func getById<T: Object>(ofType type: T.Type, id: String) -> T? {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      let result = realm.objects(type.self).filter("id == %@", id).first
      return result
    } catch {
      return nil
    }
  }
  
  func add(_ object: Object) {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      try realm.write {
        realm.add(object)
      }
    } catch let error {
      LogManager.show(error)
    }
  }
  
  func delete(_ object: Object) {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      try realm.write {
        realm.delete(object)
      }
    } catch {}
  }
  
  func update(_ object: Object, data: [String: Any]) {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      try realm.write {
        for (key, value) in data {
          object.setValue(value, forKey: key)
        }
      }
    } catch {}
  }
  
  func delete<T: Object>(ofType type: T.Type) {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      let results = realm.objects(type.self)
      try realm.write {
        realm.delete(results)
      }
    } catch {}
  }
  
  func convertToArray<T: Object>(list: List<T>) -> [T] {
    return list.map({ $0 })
  }
    
  func convertToList<T: Object>(array: [T]) -> List<T> {
    let list = List<T>()
    array.forEach { item in
      list.append(item)
    }
    return list
  }
  
  func appendToList<Parent: Object, Child: Object>(
    parent: Parent,
    keyPath: ReferenceWritableKeyPath<Parent, List<Child>>,
    object: Child
  ) {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      try realm.write {
        // Nếu child chưa thuộc Realm nào, thêm mới
        if object.realm == nil {
          realm.add(object)
        }
        parent[keyPath: keyPath].append(object)
      }
    } catch {
      LogManager.show(error)
    }
  }
  
  func deleteFromListById<Parent: Object, Child: BaseObject>(
    parent: Parent,
    keyPath: ReferenceWritableKeyPath<Parent, List<Child>>,
    id: String
  ) {
    do {
      let realm = try Realm(configuration: realmConfiguration)
      try realm.write {
        if let index = parent[keyPath: keyPath].firstIndex(where: { $0.id == id }) {
          let item = parent[keyPath: keyPath][index]
          realm.delete(item)
        }
      }
    } catch {
      LogManager.show(error)
    }
  }
}
