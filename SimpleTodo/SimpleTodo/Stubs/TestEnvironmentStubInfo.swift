//
//  TestEnvironmentStubInfo.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 1/29/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case create =  "POST"
    case read = "GET"
    case update = "PUT"
    case delete = "DELETE"
}

struct TestEnvironmentStubInfo {
    
    static let kUseHttpStubs = "useHTTPStubs"
    static let kHttpStubHeader = "HTTPSTUB"
    static let kGetMethod = "GET"
    static let kPutMethod = "PUT"
    static let kPostMethod = "POST"
    static let kSeparator = Character("|")
    
    let method: HTTPMethod
    let path: String
    let statusCode: Int32
    var contentString: String
    let contentJSON: Any
    
    
    /**
     Expects key as String with format:   "HTTPSTUB|GET|/api/todos"
     Expects value as String with format: "200|encoded-json"
     */
    init?(environmentKey key: String, value: String) {
        let keyParts = key.split(separator: TestEnvironmentStubInfo.kSeparator)
        let valueParts = value.split(separator: TestEnvironmentStubInfo.kSeparator)
        
        guard keyParts.count == 3, valueParts.count == 2,
            let stub = keyParts.first, stub == TestEnvironmentStubInfo.kHttpStubHeader,
            let httpMethod = HTTPMethod(rawValue: String(keyParts[1])),
            let code = Int32(valueParts[0]) else { return nil }
        
        
        self.method = httpMethod
        self.path = String(keyParts[2])
        self.statusCode = code
        self.contentString = String(valueParts[1])
        
        guard let data = self.contentString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        self.contentJSON = json
    }
    
    init(method: HTTPMethod = .read, path: String, statusCode: Int32 = 200, json: Any) {
        self.method = method
        self.path = path
        self.statusCode = statusCode
        self.contentJSON = json
        self.contentString = ""
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let str = String(data: data, encoding: .utf8)!
        self.contentString = str
    }
    
    init?(method: HTTPMethod = .read,
          path: String,
          statusCode: Int32 = 200,
          fileName: String,
          bundle: Bundle) {
        
        self.method = method
        self.path = path
        self.statusCode = statusCode
        
        guard let file = bundle.url(forResource: fileName, withExtension: "json"),
            let string = try? String(contentsOf: file, encoding: .utf8),
            let data = string.data(using: .utf8, allowLossyConversion: false),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        
        self.contentString = string
        self.contentJSON = json
    }
    
    static func isStubInfo(_ key: String) -> Bool {
        return key.hasPrefix(kHttpStubHeader)
    }
    
    var key: String {
        var items = [String]()
        items.append(TestEnvironmentStubInfo.kHttpStubHeader)
        items.append(method.rawValue)
        items.append(path)
        return items.joined(separator: String(TestEnvironmentStubInfo.kSeparator))
    }
    
    var value: String {
        var items = [String]()
        items.append(String(statusCode))
        items.append(contentString)
        return items.joined(separator: String(TestEnvironmentStubInfo.kSeparator))
    }
    
    var description: String {
        return "📦 (\(statusCode)) \(method.rawValue) \(path)"
    }
}
