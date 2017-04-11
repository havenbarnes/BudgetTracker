//
//  EditBudgetTableViewController.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/10/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import CoreData
import UIKit

class EditBudgetTableViewController: UITableViewController {
    
    var budget: Budget?

    var selectedColorIndex: Int = 0
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var budgetMaximumSlider: UISlider!
    @IBOutlet weak var budgetMaximumLabel: UITextField!
    @IBOutlet weak var valueSpentSlider: UISlider!
    @IBOutlet weak var valueSpentLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2 else {
            return
        }
        let oldSelectedIndexPath = IndexPath(row: selectedColorIndex, section: 2)
        let oldSelectedCell = self.tableView.cellForRow(at: oldSelectedIndexPath)
        oldSelectedCell?.accessoryType = .none
        
        let selectedIndexPath = IndexPath(row: indexPath.row, section: 2)
        let selectedCell = self.tableView.cellForRow(at: selectedIndexPath)
        selectedCell?.accessoryType = .checkmark
        
        selectedColorIndex = indexPath.row
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        createBudget()
    }
    
    func createBudget() {
        let newBudget = Budget(context: context)
        
        // If appropriate, configure the new managed object.
        newBudget.dateCreated = NSDate()
        
        if titleField.text?.replacingOccurrences(of: " ", with: "") != "" {
            newBudget.title = titleField.text
        } else {
            newBudget.title = "New Budget"
        }
        
        newBudget.maximum = Double(budgetMaximumSlider.value)
        newBudget.color = Color.allValues[selectedColorIndex].rawValue
        
        // Save the context.
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            debugPrint("Error Saving Context: \(nserror)")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func budgetTitleValueChanged(_ sender: Any) {
        if self.titleField.text?.replacingOccurrences(of: " ", with: "") != "" {
            self.navigationItem.title = self.titleField.text!
        } else {
            self.navigationItem.title = "New Budget"
        }
    }
    
    @IBAction func budgetSliderValueChanged(_ sender: Any) {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        
        self.budgetMaximumLabel.text = numberFormatter.string(from: NSNumber(value: budgetMaximumSlider.value))
    }
    
    @IBAction func budgetFieldValueChanged(_ sender: Any) {
        guard Float(budgetMaximumLabel.text!) != nil else {
            return }
        self.budgetMaximumSlider.value = Float(budgetMaximumLabel.text!)!
    }
    
    
}
