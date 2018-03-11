//
//  TodoEditorViewModel.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 1/9/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import Foundation
class TodoEditorViewModel {
    var todo: Todo
    
    init(with todo: Todo) {
        self.todo = todo
    }
    
    var title: String {
        return todo.id < 0 ? "New" : "#\(todo.id)"
    }
}
