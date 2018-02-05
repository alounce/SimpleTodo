//
//  AppDelegate.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if //true ||
            ProcessInfo.processInfo.arguments.contains(TestEnvironmentStubInfo.kUseHttpStubs) {
            setupStubs(ProcessInfo.processInfo.environment)
        }
        
        return true
    }
    
    func setupStubs(_ environment: [String: String]) {
        print("================================")
        print("🚚 REGISTER STUBS")
        print("--------------------------------")
        for (key, value) in environment {
            guard TestEnvironmentStubInfo.isStubInfo(key),
                let stubInfo = TestEnvironmentStubInfo(environmentKey: key, value: value) else { continue }
            
            stub(withTestEnvironmentInfo:stubInfo)
            print("STUB: \(stubInfo.description)")
        }
        print("================================")
    }
}
