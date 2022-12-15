//
//  Todo.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import Foundation
import Moya

class Todo {
    // MARK: - Properties
    private(set) var model: TodoModel
    private var original: TodoModel?

    var id: Int {
        get { return model.id }
        set(value) {
            guard value != model.id else { return }
            prepareForChange()
            model.id = value
        }
    }
    
    var title: String {
        get { return model.title }
        set(value) {
            guard value != model.title else { return }
            prepareForChange()
            model.title = value
        }
    }
    
    var details: String {
        get { return model.details }
        set(value) {
            guard value != model.details else { return }
            prepareForChange()
            model.details = value
        }
    }
    
    var priority: Int {
        get { return model.priority }
        set(value) {
            guard value != model.priority else { return }
            prepareForChange()
            model.priority = value
        }
    }
    
    var category: String {
        get { return model.category }
        set(value) {
            guard value != model.category else { return }
            prepareForChange()
            model.category = value
        }
    }
    
    var completed: Bool {
        get { return model.completed }
        set(value) {
            guard value != model.completed else { return }
            prepareForChange()
            model.completed = value
        }
    }
    
    var isNew: Bool { return model.isNew }
    
    // MARK: - Initializers
    
    init(model: TodoModel) {
        self.model = model
    }
    
    init() {
        self.model = TodoModel()
    }
    
    convenience init(withTitle title: String) {
        self.init()
        self.title = title
    }
    
    
    // MARK: - Network Requests
    
    open class func load(completion: @escaping ([Todo]?, Error?)->Void) {
        let provider = MoyaProvider<WebAPIClient>()
        provider.request(WebAPIClient.getTodos) { res in
            var todos: [Todo]? = nil
            var error: Error? = nil
            switch res {
            case .success(let response):
                let decoder = JSONDecoder()
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let models = try decoder.decode([TodoModel].self, from: response.data)
                    todos = models.map { Todo(model: $0) }
                } catch(let err as NSError) {
                    print("error trying to convert data to JSON. \n\(err.localizedDescription)")
                    error = err
                }
                
            case .failure(let err):
                print("Network Error: \(err.localizedDescription)")
                error = err
            }
            completion(todos, error)
        }
    }
    
    func update(completion: @escaping (Todo, Error?)->Void) {
        let provider = MoyaProvider<WebAPIClient>()
        let route = id < 0 ? WebAPIClient.addTodo(todo: self.model) : WebAPIClient.updateTodo(todo: self.model)
            provider.request(route) { [unowned self] res in
            
            switch res {
            case .success(let response):
                var error: Error? = nil
                do {
                    _ = try response.filterSuccessfulStatusCodes()

                    /* BREAKING ATTEMPT #1
                     imagine we forgot update entity from the service response
                     That means we cannot catch up generated ID for entity.
                     Add test has to fail!
                     */
                    
                    let decoder = JSONDecoder()
                    let updatedModel = try decoder.decode(TodoModel.self, from: response.data)
                    self.model = updatedModel
                    //---------------------
                    
                    
                    /* BREAKING ATTEMPT #2
                     imagine we forgot to clear dirty flag for entity at the application side so it still considered as dirty
                     Both Add and Update tests have to fail!
                     */
                    
                    self.applyChanges()
                    //---------------------
                    
                } catch let err {
                    error = err
                }
                completion(self, error)
                
            case .failure(let error):
                completion(self, error)
            }
        }
    }
    
    func delete(completion: @escaping (Todo, Error?)->Void) {
        let provider = MoyaProvider<WebAPIClient>()
        let route = WebAPIClient.deleteTodo(todoId: self.model.id)
        provider.request(route) { [unowned self] res in
            
            
            switch res {
            case .success(let response):
                var error: Error? = nil
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                } catch let err {
                    error = err
                }
                completion(self, error)
                
            case .failure(let err):
                completion(self, err)
            }
        }
    }
    

}

// MARK: - Equatable support for searching in collections
extension Todo: Equatable {
    static func ==(lhs: Todo, rhs: Todo) -> Bool {
        /* BREAKING ATTEMPT #3
         For example due to refactoring we have changed equality rules for todo instances
         and instead of comparing pointers we compare their ids.
         A lot of tests using inserted todos will fail
         That reveals another design problem
         where we didn't make sure that each inserted todo has unique id like -1, -2,..-n
         */
        
        //return lhs.id == rhs.id
        return lhs === rhs
    }
}


// MARK: - Tracking changes
extension Todo {
    
    @discardableResult
    internal func prepareForChange() -> Bool {
        let result = !isDirty
        if result {
            original = model
        }
        return result
    }
    
    @discardableResult
    public func cancelChanges() -> Bool {
        if let original = original {
            self.model = original
            return true
        }
        return false
    }
    
    @discardableResult
    internal func applyChanges() -> Bool {
        let result = isDirty
        if result {
            original = nil
        }
        return result
    }
    
    public var isDirty: Bool {
        return original != nil
    }
}


