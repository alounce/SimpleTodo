//
//  TodoModel.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import Foundation

struct TodoModel: Codable {
    
    var id: Int
    var title: String
    var details: String
    var priority: Int
    var category: String
    var completed: Bool
    
    init() {
        self.id = -1
        self.title = ""
        self.details = ""
        self.priority = 1
        self.category = ""
        self.completed = false
    }
}

// MARK: - serialization / deserialization for network layer
extension TodoModel {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let details = json["details"] as? String,
            let priority = json["priority"] as? Int,
            let category = json["category"] as? String,
            let completed = json["completed"] as? Bool else {
                return nil
        }
        self.id = id
        self.title = title
        self.details = details
        self.priority = priority
        self.category = category
        self.completed = completed
    }
    
    func asJSON() -> [String: Any] {
        var json = [String: Any]()
        if self.id > 0 {
            json["id"] = self.id
        }
        json["title"] = self.title
        json["details"] = details
        json["priority"] = priority
        json["category"] = category
        json["completed"] = completed
        return json
    }
}

