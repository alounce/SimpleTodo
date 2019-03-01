//
//  Storyboard.swift
//  SimpleTodo
//
//  Created by Oleksandr Karpenko on 3/1/19.
//  Copyright © 2019 Alexander Karpenko. All rights reserved.
//

import UIKit

enum Storyboard: String {
    
    case main = "Main"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
//    var initialViewController: UIViewController? {
//        return instance.instantiateInitialViewController()
//    }
    
    func viewController<T: UIViewController>(of type: T.Type) -> T {
        let id = (type as UIViewController.Type).storyboardId
        let scene = instance.instantiateViewController(withIdentifier: id) as! T
        return scene
    }
}


/// Convention to give SB id equal to controller name
extension UIViewController {
    static var storyboardId : String {
        return "\(self)"
    }
    
//    static func instantiate(from storyboard: Storyboard) -> Self {
//        return storyboard.viewController(of: self)
//    }
    
    func wrapIntoNavigation() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: self)
        return navigation
    }
}
