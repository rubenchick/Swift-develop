//
//  DetailThingViewController.swift
//  Daily Routine
//
//  Created by Anton Rubenchik on 18.07.2018.
//  Copyright © 2018 Anton Rubenchik. All rights reserved.
//

import UIKit

class DetailThingViewController: UIViewController {
    var thing : ThingToDo?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let thing = thing { // проверка на nil
             nameTextField.text = thing.name
             noteTextField.text = thing.note
        }
    }

    
    @IBAction func pressSaveButton(_ sender: Any) {
        if saveThing() {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pressBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    func saveThing() -> Bool {
        if thing == nil {
            thing = ThingToDo()
        }
        if nameTextField.text == "" {
            let alert = UIAlertController(title: "Внимание", message: "Не введено название ", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Хорошо", style: .cancel, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
            return false
        } else {
            thing?.name = nameTextField.text
            thing?.note = noteTextField.text
            CoreDataManager.instance.saveContext()
            return true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}