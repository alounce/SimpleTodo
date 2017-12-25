//
//  TodoAPI.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import Foundation
import Moya

enum WebAPIClient {
    case getTodos
    case getTodo(todoId: Int)
    case addTodo(todo: TodoModel)
    case updateTodo(todo: TodoModel)
    case deleteTodo(todoId: Int)
}

extension WebAPIClient: TargetType {

    var baseURL: URL {
        return URL(string: "http://localhost:3000")!
    }
    
    var path: String {
        switch self {
        case .getTodos:
            return "/api/todos"
        case .getTodo(let todoId):
            return "/api/todos/\(todoId)"
        case .addTodo:
            return "/api/todos"
        case .updateTodo(let todo):
            return "/api/todos/\(todo.id)"
        case .deleteTodo(let todoId):
            return "/api/todos/\(todoId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTodos:
            return .get
        case .getTodo:
            return .get
        case .addTodo:
            return .post
        case .updateTodo:
            return .put
        case .deleteTodo:
            return .delete
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.`default`
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .updateTodo(let model),
             .addTodo(let model):
            return .requestParameters(parameters: model.asJSON(),
                                      encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var validate: Bool {
        switch self {
//        case .getTodos:
//            return true
//            
//        case .completeTodo:
//            return true
        default:
            return false
        }
    }

    
}
