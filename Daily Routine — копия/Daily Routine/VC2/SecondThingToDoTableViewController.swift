//
//  SecondThingToDoTableViewController.swift
//  Daily Routine
//
//  Created by Anton Rubenchik on 21.07.2018.
//  Copyright © 2018 Anton Rubenchik. All rights reserved.
//

import UIKit
import CoreData

class SecondThingToDoTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let identifierCell = "thingToDoCell"
    let identifierSegue = "patternToDetail"
    var fetchRequest = ThingToDo.fetchedResultsIsActual()
    var array : [ThingToDo] = []
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        // ??????? not test it
//        setOrder() // need for record same priority because they don't everyday show
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setOrder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequest.delegate = self
        
        do {
            try fetchRequest.performFetch()
        } catch {
            print(error)
        }
        tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func doubleTapped() {
        tableView.isEditing = !tableView.isEditing
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = fetchRequest.fetchedObjects?.count {
            return count
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        if let thingToDo = fetchRequest.object(at: indexPath) as? ThingToDo {
            cell.textLabel?.text = thingToDo.name! + " \(String(describing: thingToDo.priority))"
        }
        
        return cell
    }
    //MARK: Move to other page
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print(indexPath)
        if let thing = fetchRequest.object(at: indexPath) as? ThingToDo {
            performSegue(withIdentifier: identifierSegue, sender: thing)
        }
    }
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: identifierSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifierSegue {
            let controller = segue.destination as! SecondDetailViewController
            let thingToDoActualArray = fetchRequest.fetchedObjects?.count
            controller.count = thingToDoActualArray
            controller.thingToDo = sender as? ThingToDo
        }
    }
    //MARK: Delegate for editing Table
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let thingToDo = fetchRequest.object(at: indexPath) as! ThingToDo
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
                cell.textLabel?.text = thingToDo.name! + " \(String(describing: thingToDo.priority))"
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let temp = fetchRequest.fetchedObjects as? [ThingToDo] {
            setOrder()
            array = temp
            array[sourceIndexPath.row].priority = NSDecimalNumber(value: destinationIndexPath.row)

            if sourceIndexPath.row < destinationIndexPath.row {
                for i in sourceIndexPath.row+1...destinationIndexPath.row {
                    array[i].priority = NSDecimalNumber(value: i - 1)
                }
            } else {
                for i in (destinationIndexPath.row...sourceIndexPath.row-1).reversed() {
                    array[i].priority = NSDecimalNumber(value: i + 1)
                }
            }
            CoreDataManager.instance.saveContext()
            tableView.reloadData()
        }
    }
    func setOrder() {

        if let temp = fetchRequest.fetchedObjects as? [ThingToDo] {
            if temp.count < 2 {
                if temp.count == 1 {
                    array[0].priority = 0
                }
            } else {
                array = temp
                array[0].priority = 0
                if array.count > 0 {
                    for i in 1...array.count-1 {
                        array[i].priority = NSDecimalNumber(value: Int(truncating: array[i-1].priority!) + 1)
                    }
                }
                CoreDataManager.instance.saveContext()
                tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("DELETE___________________++++++++++++++++++__________________")
            // lifehack
            let reserve = ThingToDo()
            reserve.name = "TEst Delete"
            reserve.priority = 999
            CoreDataManager.instance.saveContext()
            if let thing = fetchRequest.object(at: indexPath) as? ThingToDo {
                thing.isActual = false
                let historyFindThisThingToDo = ThingToDo.fetchedResultsHistoryToday(forThingToDo: thing)
                do {
                    try historyFindThisThingToDo.performFetch()
                    historyFindThisThingToDo.delegate = self
                } catch {
                    print(error)
                }
                if let historyToDelete = historyFindThisThingToDo.fetchedObjects?.first as? NSManagedObject {
                    CoreDataManager.instance.persistentContainer.viewContext.delete(historyToDelete)
                    print("delete HIstory- finished")
                }
             }
            let managedObject = fetchRequest.fetchedObjects?.last as! NSManagedObject
            CoreDataManager.instance.persistentContainer.viewContext.delete(managedObject)
            CoreDataManager.instance.saveContext()
        }
    }

}
