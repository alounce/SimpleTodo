//
//  TodoEditorViewModel.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 1/9/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import Foundation
import Alamofire

protocol TodoEditorViewModelProtocol {
    var todo: Todo { get set }
    var title: String { get }
    init(with todo: Todo)
    func update(completion: @escaping (Result<Todo>) -> Void)
}

class TodoEditorViewModel: TodoEditorViewModelProtocol {
    var todo: Todo
    
    required init(with todo: Todo) {
        self.todo = todo
    }
    
    var title: String {
        return todo.id < 0 ? "New" : "#\(todo.id)"
    }
    
    func update(completion: @escaping (Result<Todo>) -> Void) {
        
        todo.update { todo, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(todo))
        }
    }
}
