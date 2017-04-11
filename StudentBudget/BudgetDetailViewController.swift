//
//  DetailViewController.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/8/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        
    }

    var budget: Budget? {
        didSet {
            configureView()
        }
    }
}
