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
    @IBOutlet weak var toGoLabel: UILabel!
    
    var budget: Budget! {
        didSet {
            configureCell()
        }
    }
    
    func configureCell() {
        updateButton.layer.borderColor = UIColor.black.cgColor
        budgetTitleLabel.text = budget.title
        progressView.backgroundColor = UIColor(hex: budget.color!)
        let progressPercentage = budget.value / budget.maximum
        progressViewWidth.constant = self.frame.width * CGFloat(progressPercentage) + 10.0
        if progressViewWidth.constant < 10 {
            progressViewWidth.constant = 10
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        
        var leftToGoValue = NSNumber(value: (budget.maximum - budget.value))
        if leftToGoValue.doubleValue < 0 {
            leftToGoValue = 0
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
            
            self.toGoLabel.text = leftToGoValue == 0 ? "Budget Spent" : "$\(numberFormatter.string(from: leftToGoValue)!) Left To Spend"
        }, completion: nil)
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        
        guard !self.isEditing else { return }
        
        let tableView = self.superview!.superview! as! UITableView
        let tableViewController = tableView.dataSource as! BudgetsTableViewController
        
        let alert = UIAlertController(title: "How much did you spend?", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            let dollarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
            dollarLabel.text = "$"
            dollarLabel.contentMode = .center
            textField.leftViewMode = .always
            textField.leftView = dollarLabel
            textField.placeholder = "0.00"
            textField.keyboardType = .decimalPad
            textField.font = UIFont(name: ".SFUIDisplay-Semibold", size: 20)!
            textField.borderStyle = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Spend", style: .default, handler: { (_) in
            
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
