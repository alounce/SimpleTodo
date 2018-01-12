//
//  MockTodosViewModel.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/9/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import UIKit
@testable import SimpleTodo

/* POI: Using protocols to create Mock:
 this is a D - Dependency Inverion technique (SOLID)
 which is prefferable way from design point of view (much cleaner and extensible)
 It allows to create "pure" Mock, however it requires some boilerplate coding and can lead to overall complexity of the product. Use it with care. Try to keep things as Simple as it possible
 
 Used in List/TodosViewController.swift
 */

class MockTodosViewModel: TodosViewModelProtocol {

    var downloadShouldFail = false
    var updateShouldFail = false
    var deleteShouldFail = false
    
    var downloadWasCalled = false
    var updateWasCalled = false
    var deleteWasCalled = false
    
    var collectionWasSynced = false
    var lastError: Error? = nil
    
    var collection = [Todo(withTitle: "Do first"),
                      Todo(withTitle: "Do second"),
                      Todo(withTitle: "Do third"),
                      Todo(withTitle: "Do fourth"),
                      Todo(withTitle: "Do fifth")]
    
    func numberOfGroups() -> Int {
        return 1
    }
    
    func numberOfItems(inGroup groupIndex: Int) -> Int {
        return collection.count
    }
    
    func item(forRow rowIndex: Int, inGroup groupIndex: Int) -> Todo? {
        if groupIndex != 0 { return nil }
        return collection[rowIndex]
    }
    
    func item(byIndexPath indexPath: IndexPath) -> Todo? {
        if indexPath.section != 0 { return nil }
        return collection[indexPath.row]
    }
    
    func item(byId id: Int) -> Todo? {
        return collection.first(where: { $0.id == id })
    }
    
    func download(completion: @escaping ([Todo]?, Error?) -> Void) {
        downloadWasCalled = true
        if downloadShouldFail {
            lastError = NSError(domain: "com.vivint.test", code: 999, userInfo: [kCFErrorLocalizedDescriptionKey as String : "Test error"])
            completion(nil, lastError)
        } else {
            completion(collection, nil)
        }
    }
    
    func update(_ todo: Todo, completion: @escaping (Todo, Error?) -> Void) {
        updateWasCalled = true
        
        if updateShouldFail {
            lastError = NSError(domain: "com.vivint.test", code: 999, userInfo: [kCFErrorLocalizedDescriptionKey as String : "Test error"])
        }
        completion(collection.first!, lastError)
    }
    
    func delete(_ todo: Todo, completion: @escaping (Todo, Error?) -> Void) {
        deleteWasCalled = true
        
        if deleteShouldFail {
            lastError = NSError(domain: "com.vivint.test", code: 999, userInfo: [kCFErrorLocalizedDescriptionKey as String : "Test error"])
        }
        completion(collection.first!, lastError)
    }
    
    func syncCollection(with todo: Todo, modificationType: ModificationType) -> IndexPath? {
        collectionWasSynced = true
        if modificationType == .insert {
            collection.append(todo)
            return IndexPath(row: collection.count - 1, section: 0)
            
        }
        if modificationType == .delete {
            let idx = collection.index(of: todo)!
            collection.remove(at:idx)
            return IndexPath(row: idx, section: 0)
            
        }
        return IndexPath(row: collection.index(of: todo)!, section: 0)
    }
}
