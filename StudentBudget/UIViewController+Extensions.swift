//
//  UIViewController+Extensions.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/10/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

extension UIViewController {
    func instantiate(_ storyboardIdentifier: String) -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier)
        return viewController
    }
    
    func present(_ storyboardIdentifier: String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier)
        self.present(viewController, animated: true, completion: nil)
    }
    
    func show(_ storyboardIdentifier: String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardIdentifier)
        self.show(viewController, sender: self)
    }
}

