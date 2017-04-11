//
//  BudgetCell.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/10/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

class BudgetCell: UITableViewCell {
    @IBOutlet weak var budgetTitleLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var updateButton: UIButton!
    
    var budget: Budget! {
        didSet {
            configureCell()
        }
    }
    
    func configureCell() {
        updateButton.layer.borderColor = UIColor.black.cgColor
        budgetTitleLabel.text = budget.title
        let progressPercentage = budget.value / budget.maximum
        progressView.backgroundColor = UIColor(hex: budget.color!)
        progressViewWidth.constant = App.shared.window.frame.width * CGFloat(progressPercentage) + 10.0
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        
        let tableView = self.superview!.superview! as! UITableView
        let tableViewController = tableView.dataSource as! BudgetsTableViewController
        
        let alert = UIAlertController(title: "How much did you spend?", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = ""
            textField.keyboardType = .decimalPad
            textField.font = UIFont(name: ".SFUIDisplay-Semibold", size: 20)!
            textField.borderStyle = .none
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (_) in
            
            if let addedAmount = Double(alert.textFields![0].text!) {
                self.budget.value += addedAmount
            }
            self.configureCell()
            
            try? tableViewController.fetchedResultsController.managedObjectContext.save()
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        tableViewController.present(alert, animated: true, completion: nil)
    }
    
}
