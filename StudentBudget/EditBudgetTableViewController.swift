//
//  EditBudgetTableViewController.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/10/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import CoreData
import UIKit

class EditBudgetTableViewController: UITableViewController, UITextFieldDelegate {
    
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
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedColor()
    }
    
    func configureUI() {
        self.valueSpentLabel.delegate = self
        guard budget != nil else {
            self.navigationItem.title = "New Budget"
            budgetSliderValueChanged(budgetMaximumSlider)
            valueSpentSliderValueChanged(valueSpentSlider)
            return
        }
        
        self.navigationItem.title = budget!.title
        self.titleField.text = budget!.title
        self.budgetMaximumSlider.value = Float(budget!.maximum)
        self.valueSpentSlider.value = Float(budget!.value)
        
        budgetSliderValueChanged(budgetMaximumSlider)
        valueSpentSliderValueChanged(valueSpentSlider)
    }
    
    func setSelectedColor() {
        guard budget != nil else {
            return
        }
        
        for index in 0..<Color.allValues.count {
            let color = Color.allValues[index]
            if budget!.color! == color.rawValue {
                selectedColorIndex = index
                let indexPath = IndexPath(row: index, section: 3)
                tableView(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 3 else {
            return
        }
        if indexPath.row == selectedColorIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 3 else {
            return
        }
        let oldSelectedIndexPath = IndexPath(row: selectedColorIndex, section: 3)
        let oldSelectedCell = self.tableView.cellForRow(at: oldSelectedIndexPath)
        oldSelectedCell?.accessoryType = .none
        
        let selectedIndexPath = IndexPath(row: indexPath.row, section: 3)
        let selectedCell = self.tableView.cellForRow(at: selectedIndexPath)
        selectedCell?.accessoryType = .checkmark
        
        selectedColorIndex = indexPath.row
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let budgetToBeSaved: Budget!
        if budget != nil {
            // Just update existing budget
            budgetToBeSaved = budget
            budgetToBeSaved.dateUpdated = Date() as NSDate
        } else {
            budgetToBeSaved = Budget(context: context)
            budgetToBeSaved.dateCreated = Date() as NSDate
        }
        saveAndExit(budget: budgetToBeSaved)
    }
    
    func saveAndExit(budget: Budget) {        
        if titleField.text?.replacingOccurrences(of: " ", with: "") != "" {
            budget.title = titleField.text
        } else {
            budget.title = "New Budget"
        }
        
        // Keep the slider input from being TOO precise
        budget.maximum = Double(Int(budgetMaximumSlider.value))
        budget.value = Double(Int(valueSpentSlider.value))
        
        budget.color = Color.allValues[selectedColorIndex].rawValue
        
        // Save the context.
        try? context.save()
        
        if self.budget != nil {
            self.navigationController?.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController!.popViewController(animated: true)
        }
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
        
        UIView.animate(withDuration: 0.3, animations: {
            self.valueSpentSlider.maximumValue = self.budgetMaximumSlider.value
            
            if Float(self.valueSpentLabel.text!)! > self.budgetMaximumSlider.value {
                self.valueSpentLabel.text = numberFormatter.string(from: NSNumber(value: self.budgetMaximumSlider.value))
            }
        })
        
        self.budgetMaximumLabel.text = numberFormatter.string(from: NSNumber(value: budgetMaximumSlider.value))
    }
    
    @IBAction func budgetFieldValueChanged(_ sender: Any) {
        guard Float(budgetMaximumLabel.text!) != nil else {
            return }
        self.budgetMaximumSlider.value = Float(budgetMaximumLabel.text!)!
        budgetSliderValueChanged(sender)
    }
    
    @IBAction func valueSpentSliderValueChanged(_ sender: Any) {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        
        self.valueSpentLabel.text = numberFormatter.string(from: NSNumber(value: valueSpentSlider.value))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if valueSpentLabel.text!.characters.count - range.length + string.characters.count > 6 {
            return false
        }
        return true
    }
    
    @IBAction func valueSpentFieldValueChanged(_ sender: Any) {
        guard Float(valueSpentLabel.text!) != nil else {
            return }
        self.valueSpentSlider.value = Float(valueSpentLabel.text!)!
    }
}
