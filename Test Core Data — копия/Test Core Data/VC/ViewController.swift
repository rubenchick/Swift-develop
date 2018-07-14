
//  ViewController.swift
//  Test Core Data
//
//  Created by Anton Rubenchik on 05.07.2018.
//  Copyright © 2018 Anton Rubenchik. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//
//        // доступ к классу appDelegate
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        // create a new context in this container
//        let context = appDelegate.persistentContainer.viewContext
//        
////         create new emtity for new records
//        let entity = NSEntityDescription.entity(forEntityName: "Customer", in: context)
//        
//        // variant first. low level
//        let newCustomer = NSManagedObject(entity: entity!, insertInto: context)
//
//        newCustomer.setValue("Ltd Kremlin", forKey: "name")
//        newCustomer.setValue("bad", forKey: "info")
//        
////         varianty second. high level.
//        let newCustomer = NSManagedObject(entity: entity!, insertInto: context) as! Customer
//        newCustomer.name = "VTC"
//        newCustomer.info = "very bad company"
//
//        // save new record
//        if context.hasChanges {
//            print("Need save")
//            appDelegate.saveContext()
//        }
//        
////        get data
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Customer")
////         фильтруем вытаскиваемые данные
//        request.predicate = NSPredicate(format: "info = %@", "noromal job");
//        request.predicate = NSPredicate(format: "info contains %@", "job");
//        request.predicate = NSPredicate(format: "name contains %@", "Ltd");
//        
////         составной фильтр
//        let predicate1 = NSPredicate(format: "name contains %@", "Ltd");
//        let predicate2 = NSPredicate(format: "info contains %@", "perfect");
//        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates:[predicate1,predicate2])
//        request.predicate = compound
//        
//        
//        // вытаскиваем данные без фильтра
//        request.returnsObjectsAsFaults = false
//        do {
//             let results = try context.fetch(request)
//            print("Count : \(results.count)")
//            for result in results as! [NSManagedObject] {
//                print("name - \(result.value(forKey: "name")!)  info - \(result.value(forKey: "info")!)")
//            }
//        } catch {
//            print(error)
//        }
    }
}

