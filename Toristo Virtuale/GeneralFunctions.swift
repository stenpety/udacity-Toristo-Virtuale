//
//  GlobalFunctions.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 12/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import UIKit

class General: NSObject {
    
    // Shared instance
    static let sharedInstance = General()
    
    // Empty private init to prohibit initialization of this class
    private override init() {}
    
    // MARK: Show alert
    func showAlert(_ viewController: UIViewController, title: String, message: String?, actionTitle: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Updates on Main queue
    func performUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    
}


