//
//  MasterViewController.swift
//  StudentBudget
//
//  Created by Haven Barnes on 4/8/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class BudgetsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var detailViewController: EditBudgetTableViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        let newMonthButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startNewMonth))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewBudget))
        navigationItem.rightBarButtonItems = [addButton, newMonthButton]
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? EditBudgetTableViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func createNewBudget() {
        let createBudgetVC = instantiate("EditBudgetTableViewController") as! EditBudgetTableViewController
        createBudgetVC.context = self.fetchedResultsController.managedObjectContext
        self.navigationController?.show(createBudgetVC, sender: nil)
    }
    
    func startNewMonth() {
        guard fetchedResultsController.fetchedObjects != nil
            && fetchedResultsController.fetchedObjects?.count != 0 else {
            return
        }
        
        let alert = UIAlertController(title: "Start A New Month?", message: "All Of Your Budgets Will Be Reset To Zero", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Reset Budgets", style: .destructive, handler: {
            action in
            
            let budgets = self.fetchedResultsController.fetchedObjects ?? []
            for budget in budgets {
                budget.value = 0.0
            }
            try? self.fetchedResultsController.managedObjectContext.save()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! EditBudgetTableViewController
                controller.budget = object
                controller.context = self.fetchedResultsController.managedObjectContext
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        let budget = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withBudget: budget)
        return cell
    }
    
    func configureCell(_ cell: BudgetCell, withBudget budget: Budget) {
        cell.budget = budget
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - DZNEmptySet delegate methods
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You Don't Have Any Budgets Yet."
        let attributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Semibold", size: 20)!,
                          NSForegroundColorAttributeName: UIColor.black]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = "Create One Now"
        
        let attributes: [String: Any] =
            [NSFontAttributeName: UIFont(name: ".SFUIText-Medium", size: 16)!,
             NSForegroundColorAttributeName: UIColor.orange]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        createNewBudget()
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Budget> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 30
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "maximum", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            debugPrint("Error Fetching: \(nserror)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Budget>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!) as! BudgetCell!, withBudget: anObject as! Budget)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!) as! BudgetCell!, withBudget: anObject as! Budget)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

