//
//  TodosViewModel.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import Foundation


protocol TodosViewModelProtocol {
    func numberOfGroups()->Int
    func numberOfItems(inGroup groupIndex: Int)->Int
    func item(forRow rowIndex: Int, inGroup groupIndex: Int) -> Todo?
    func item(byIndexPath indexPath: IndexPath) -> Todo?
    func item(byId id: Int) -> Todo?
    func download(completion: @escaping ([Todo]?, Error?) -> Void)
    func update(_ todo: Todo, completion: @escaping (Todo, Error?) -> Void)
    func delete(_ todo: Todo, completion: @escaping (Todo, Error?) -> Void)
    func syncCollection(with todo: Todo, modificationType: ModificationType) -> IndexPath?
}

class TodosViewModel: TodosViewModelProtocol {
    
    // MARK: - Data Source
    
    var displayData: [Todo]?
    
    func numberOfGroups()->Int {
        return 1
    }
    
    func numberOfItems(inGroup groupIndex: Int)->Int {
        if let displayData = displayData, groupIndex == 0 {
            return displayData.count
        }
        return 0
    }
    
    func item(forRow rowIndex: Int, inGroup groupIndex: Int = 0) -> Todo? {
        guard groupIndex == 0,
            let displayData = displayData,
            (0 ... displayData.count - 1).contains(rowIndex) else {
                return nil
        }
        
        return displayData[rowIndex]
    }
    
    func item(byIndexPath indexPath: IndexPath) -> Todo? {
        return item(forRow: indexPath.row, inGroup: indexPath.section)
    }
    
    func indexPath(forItem item: Todo) -> IndexPath? {
        if let row = self.displayData?.index(of: item) {
            return IndexPath(row: row, section: 0)
        }
        return nil
    }
    
    func item(byId id: Int) -> Todo? {
        return self.displayData?.first(where: { $0.id == id })
    }
    
    
    // MARK: - Modification
    func download(completion: @escaping ([Todo]?, Error?)->Void) {
        Todo.load { (todos, error) in
            self.displayData = todos
            completion(todos, error)
        }
    }
    
    func update(_ todo: Todo, completion: @escaping (Todo, Error?)->Void) {
        todo.update { todo, error in
            completion(todo, error)
        }
    }
    
    func delete(_ todo: Todo, completion: @escaping (Todo, Error?)->Void) {
        todo.delete { todo, error in
            completion(todo, error)
        }
    }
    
    func syncCollection(with todo: Todo, modificationType: ModificationType) -> IndexPath? {
        var result: IndexPath? = nil
        
        if modificationType == .insert {
            self.displayData?.append(todo)
        }
        
        
        if let row = self.displayData?.index(of:todo) {
            result = IndexPath(row: row, section: 0)
            
            /* BREAKING ATTEMPT #4
             Imagine during refactoring we forgot to sync up changes after Delete operation
            */
            
            if modificationType == .delete  {
                self.displayData?.remove(at: row)
            }
            //---------------------
        }
        
        
        
        return result
    }
    
}
