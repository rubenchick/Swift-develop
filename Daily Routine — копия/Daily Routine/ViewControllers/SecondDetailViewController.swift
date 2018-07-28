//
//  SecondDetailViewController.swift
//  Daily Routine
//
//  Created by Anton Rubenchik on 21.07.2018.
//  Copyright © 2018 Anton Rubenchik. All rights reserved.

// Закончил полностью функционал Weekly для нового Thing.
// + 1. Нужно грузить weekly для уже существующих thing
// + 2. Сделать monthly.
// 3. Отображать в списке Today согласно weekly и monthly
// 4. Проверить, где еще иcпользуется Today. Может быть moved???
// 5. После добавления 3-х записей, указать, как можно менять порядок/удалить
// 6. При удалении thing in Today сообщить, что он удалится только сегодня, и нужно удалить в списке, если на всегда
// 7. При первом открытии, указать что это за страница, и где посмотреть список всех дел
// 8. ДОбавить срок выполнения. % 5 дней
// AppStore
// 9. Сделать обучающие слайды???
// 10. Английская версия
// 11. Notification. Сколько не прочитанных сообщений
// 12. Почистить код.

import UIKit
import CoreData

class SecondDetailViewController: UIViewController {
    // MARK: Var
    var thingToDo: ThingToDo?
    var count: Int?
    // MARK: @IBOutlet
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noteTExtField: UITextField!
    @IBOutlet weak var addInfoToNoteLabel: UILabel!
    @IBOutlet weak var countTimesTextField: UITextField!
    @IBOutlet weak var infoToNoteSegmentControl: UISegmentedControl!
    @IBOutlet weak var countTimesStepperOutlet: UIStepper!
    @IBOutlet weak var weeklyView: UIView!
    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var weeklySwitch: UISwitch!
    @IBOutlet weak var monthlySwitch: UISwitch!
    @IBOutlet weak var dailySwitch: UISwitch!
    @IBOutlet weak var pressSaveButton: UIBarButtonItem!
    @IBOutlet weak var pressCancelButton: UIBarButtonItem!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var readyWeeklyViewOutlet: UIButton!
    
    // MARK: own function
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.statusBarView?.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let thingToDo = thingToDo {
            nameTextField.text = thingToDo.name
            noteTExtField.text = thingToDo.note
            if thingToDo.weekly {
                installSwitchForDaily(howOften: 2)
                if let weekly = thingToDo.week {
                    createElementForWeeklyView()
//                    bad idea, I known
                    for i in 1...7 {
                        if let item = self.view.viewWithTag(i) as? UIButton {
                            if (weekly.monday) && (i == 1) { item.isSelected = true }
                            if (weekly.tuesday) && (i == 2) { item.isSelected = true }
                            if (weekly.wednesday) && (i == 3) { item.isSelected = true }
                            if (weekly.thursday) && (i == 4) { item.isSelected = true }
                            if (weekly.friday) && (i == 5) { item.isSelected = true }
                            if (weekly.saturday) && (i == 6) { item.isSelected = true }
                            if (weekly.sunday) && (i == 7) { item.isSelected = true }
                        }
                    }
                }
            } else {
                if thingToDo.monthly {
                    installSwitchForDaily(howOften: 3)
                    createElementForMonthlyView()
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DayOfMonth")
//                    let sortDescription = NSSortDescriptor(key: "date", ascending: true)
//                    request.sortDescriptors = [sortDescription]
                    let predicate = NSPredicate(format: "%K == %@", "thingToDo", thingToDo)
                    request.predicate = predicate
                    do {
                        let dayOfMonth = try CoreDataManager.instance.persistentContainer.viewContext.fetch(request)
                        if let days = dayOfMonth as? [DayOfMonth] {
                            for day in days {
                                if let i = day.date?.intValue {
                                    if let item = self.view.viewWithTag(100 + i) as? UIButton {
                                        print(i)
                                        item.isSelected = true
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        
//        weeklyView.frame.size.height = weeklyView.frame.size.width / 2
        // tap for WeeklyLabel
        let tapGestureForWeeklyLabel = UITapGestureRecognizer(target: self, action: #selector(tapForWeeklyLabel))
        weeklyLabel.isUserInteractionEnabled = true
        weeklyLabel.addGestureRecognizer(tapGestureForWeeklyLabel)
        
        let tapGestureForMonthlyLabel = UITapGestureRecognizer(target: self, action: #selector(tapForMonthlyLabel))
        monthlyLabel.isUserInteractionEnabled = true
        monthlyLabel.addGestureRecognizer(tapGestureForMonthlyLabel)
    }
    // MARK: Button on Navigation
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if saveThingToDo() {
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Внимание", message: "Не введено название ", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Хорошо", style: .cancel, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    func addInfoToNote(atIndex index: Int) -> String{
        let timeForDayDictionary = [2: ["утром","вечером"],
                                    3: ["утром","днем","вечером"],
                                    4: ["утром","до обеда","после обеда","вечером"],
                                    5: ["утром","до обеда","после обеда","вечером","ночью"]]
        let endOfNumbersArray = ["-ой","-ый","-ой","-ий","-ый","-ый","-ой","-ой","-ой","-ой","-ой"]
        var addInfo = ""
        if let times = Int(countTimesTextField.text!) {
            if times > 1 {
                if infoToNoteSegmentControl.selectedSegmentIndex != 0 {
                    if infoToNoteSegmentControl.selectedSegmentIndex == 1 {
                        addInfo = "(\(index)\(endOfNumbersArray[index]) раз) "
                    } else {
                        let timeForDayArray = timeForDayDictionary[times]
                        addInfo = "( " + timeForDayArray![index-1] + " ) "
                    }
                }
            }
        }
        return addInfo
    }
    // MARK: For Save Record
    // record from WeekView To ThingToDo.Week entity Week
    func record(week: Week){
        for i in 1...7 {
            if let newButton = self.view.viewWithTag(i) as? UIButton {
                if newButton.isSelected {
                    switch i {
                    case 1: week.monday = true
                    case 2: week.tuesday = true
                    case 3: week.wednesday = true
                    case 4: week.thursday = true
                    case 5: week.friday = true
                    case 6: week.saturday = true
                    case 7: week.sunday = true
                    default: break
                    }
                } else {
                    switch i {
                    case 1: week.monday = false
                    case 2: week.tuesday = false
                    case 3: week.wednesday = false
                    case 4: week.thursday = false
                    case 5: week.friday = false
                    case 6: week.saturday = false
                    case 7: week.sunday = false
                    default: break
                    }
                }
            }
        }
    }
    
    func deleteOldRecordInDayOfMonthFrom(thingToDo: ThingToDo){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DayOfMonth")
        let predicate = NSPredicate(format: "%K == %@", "thingToDo", thingToDo)
        request.predicate = predicate
        do {
            let dayOfMonth = try CoreDataManager.instance.persistentContainer.viewContext.fetch(request) as! [NSManagedObject]
            for day in dayOfMonth {
                CoreDataManager.instance.persistentContainer.viewContext.delete(day)
            }
            CoreDataManager.instance.saveContext()
        } catch {
            print(error)
        }
    }
    
    // this is bad code. ;-(
    func saveThingToDo() -> Bool {
        if nameTextField.text != "" {
            // newRecord
            if thingToDo == nil {
                thingToDo = ThingToDo()
                let history = History()
                history.date = Date() as NSDate
                history.isDone = false
                history.thingToDo = thingToDo
                if let count = count {
                    thingToDo?.priority = NSDecimalNumber(value: count)
                } else {
                    thingToDo?.priority = NSDecimalNumber(value: 100)
                }
                thingToDo?.isActual = true
            }
            // oldRecord or continue newRecord
            if dailySwitch.isOn {
                thingToDo?.daily = true
                thingToDo?.weekly = false
                thingToDo?.monthly = false
                
            } else {
                if weeklySwitch.isOn {
                    thingToDo?.daily = false
                    thingToDo?.weekly = true
                    thingToDo?.monthly = false
//                    if thingToDo?.week != nil {
//                        record(week: (thingToDo?.week)!)
//                    } else {
//                        let week = Week()
//                        thingToDo?.week = week
//                        record(week: (thingToDo?.week)!)
//                    }
                    
                    if thingToDo?.week == nil {
                        let week = Week()
                        thingToDo?.week = week
                    }
                    
                    record(week: (thingToDo?.week)!)
//                    let weekly = Week()

//                    thingToDo?.week = weekly
                } else {
                    if monthlySwitch.isOn {
                        print("monthlySwitch")
                        thingToDo?.daily = false
                        thingToDo?.weekly = false
                        thingToDo?.monthly = true
                        // delete old record in DayOfMonth
                        
                        deleteOldRecordInDayOfMonthFrom(thingToDo: thingToDo!)
                        
                        
                        for i in 1...31 {
                            if let newButton = self.view.viewWithTag(100 + i) as? UIButton {
                                if newButton.isSelected {
                                    let dayOfMonth = DayOfMonth()
                                    dayOfMonth.date = NSDecimalNumber(decimal: Decimal(i))
                                    dayOfMonth.thingToDo = thingToDo
                                }
                            }
                        }
                    }
                }
                
            }
            thingToDo?.name = nameTextField.text
            thingToDo?.note = addInfoToNote(atIndex: 1) + noteTExtField.text!
            CoreDataManager.instance.saveContext()
            
            if let times = Int(countTimesTextField.text!) {
                if times > 1 {
                    for i in 2...times {
                        let newThingToDo = ThingToDo()
                        let newHistory = History()
                        newHistory.date = Date() as NSDate
                        newHistory.isDone = false
                        newHistory.thingToDo = newThingToDo
                        if let count = count {
                            newThingToDo.priority = NSDecimalNumber(value: count + i)
                        } else {
                            newThingToDo.priority = NSDecimalNumber(value: 100)
                        }
                        newThingToDo.isActual = true
                        newThingToDo.name = nameTextField.text
                        newThingToDo.note = addInfoToNote(atIndex: i) + noteTExtField.text!
                        if dailySwitch.isOn {
                            newThingToDo.daily = true
                        } else {
                            if weeklySwitch.isOn {
                                newThingToDo.weekly = true
                                let week = Week()
                                record(week: week)
//                                for i in 1...7 {
//                                    if let newButton = self.view.viewWithTag(i) as? UIButton {
//                                        if newButton.isSelected {
////                                          bad idea, I known
//                                            switch i {
//                                            case 1: weekly.monday = true
//                                            case 2: weekly.tuesday = true
//                                            case 3: weekly.wednesday = true
//                                            case 4: weekly.thursday = true
//                                            case 5: weekly.friday = true
//                                            case 6: weekly.saturday = true
//                                            case 7: weekly.sunday = true
//                                            default: break
//                                            }
//                                        }
//                                    }
//                                }
                                newThingToDo.week = week
                            } else {
                                if monthlySwitch.isOn {
                                    print("monthlySwitch")
                                    newThingToDo.monthly = true
                                    for i in 1...31 {
                                        if let newButton = self.view.viewWithTag(100 + i) as? UIButton {
                                            if newButton.isSelected {
                                                let dayOfMonth = DayOfMonth()
                                                dayOfMonth.date = NSDecimalNumber(decimal: Decimal(i))
                                                dayOfMonth.thingToDo = newThingToDo
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    CoreDataManager.instance.saveContext()
                }
            }
            return true
        } else {
            return false
        }
    }
    // rule for work Stepper
    @IBAction func countTimesStepper(_ sender: UIStepper) {
        
        countTimesTextField.text = "\(Int(countTimesStepperOutlet.value))"
        if countTimesStepperOutlet.value > 1 {
            addInfoToNoteLabel.isEnabled = true
            infoToNoteSegmentControl.isEnabled  = true
        } else {
            addInfoToNoteLabel.isEnabled = false
            infoToNoteSegmentControl.isEnabled = false
        }
        if countTimesStepperOutlet.value > 5 {
            infoToNoteSegmentControl.setEnabled(false, forSegmentAt: 2)
            infoToNoteSegmentControl.selectedSegmentIndex = 1
        } else {
            infoToNoteSegmentControl.setEnabled(true, forSegmentAt: 2)
        }
    }
    
    // убрать клавиатуру, когда нажали на "другую" часть экрана
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // tap for WeeklyLabel
    @objc func tapForWeeklyLabel(sender: UITapGestureRecognizer) {
        guard let _ = sender.view as? UILabel else { return }
        if weeklySwitch.isOn {
            weeklyView.isHidden = false
            enabledElementInVC(is: false)
            createElementForWeeklyView()
        }
    }
    // tap for MonthlyLabel
    @objc func tapForMonthlyLabel(sender: UITapGestureRecognizer) {
        guard let _ = sender.view as? UILabel else { return }
        if monthlySwitch.isOn {
            monthlyView.isHidden = false
            enabledElementInVC(is: false)
            createElementForMonthlyView()
        }
    }

    // tag 1...7 - bad idea, I known
    func createElementForWeeklyView() {
        
        weeklyView.layer.cornerRadius = 15
        let dayArray = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"] // tag 1...7
        let widht = Int(weeklyView.frame.size.width / 11)
        for i in 1...7 {
            // проверка создавались ли уже кнопки
            if let _ = self.view.viewWithTag(i) as? UIButton {
            } else {
                let dayButton = UIButton(type: .system)
                dayButton.frame = CGRect(x: Int(Double(widht)*1) + (i - 1) * Int(Double(widht) * 1.4) , y: widht * 4, width: widht, height: widht)
                dayButton.layer.cornerRadius = CGFloat(Double(widht) / 5)
                dayButton.clipsToBounds = true
                dayButton.backgroundColor = .lightGray
                dayButton.setTitle(dayArray[i - 1], for : UIControlState.normal)
                dayButton.setTitleColor(UIColor(red: 51/255, green: 102/255, blue: 153/255, alpha: 1), for: .normal)
                dayButton.setTitleColor(.lightGray, for: .selected)
                dayButton.tintColor = UIColor(red: 51/255, green: 102/255, blue: 153/255, alpha: 1)
                dayButton.setBackgroundColor(UIColor(red: 51/255, green: 102/255, blue: 153/255, alpha: 1), for: .selected)
                dayButton.tag = i
                dayButton.addTarget(self, action: #selector(pressButton), for: .touchDown)
                weeklyView.addSubview(dayButton)
            }
        }
        readyWeeklyViewOutlet.sizeToFit()
        weeklyView.frame.size.height = CGFloat(widht * 8)
        readyWeeklyViewOutlet.center.x = CGFloat(Double(widht) * 5.6)
        readyWeeklyViewOutlet.center.y = CGFloat(Double(widht) * 6.5)
    }
    
    // tag 101...131
    func createElementForMonthlyView() {
        
        monthlyView.layer.cornerRadius = 15
        let widht = Int(monthlyView.frame.size.width / 11)
        var row = 1
        var column = 1
        for i in 1...31 {
            // проверка создавались ли уже кнопки
            if let _ = self.view.viewWithTag(100+i) as? UIButton {
            } else {
                let dayButton = UIButton(type: .system)
                dayButton.frame = CGRect(x: Int(Double(widht)*1) + (column - 1) * Int(Double(widht) * 1.4) , y: Int(Double(widht) * (3.5 + 1.4 * Double((row - 1)) )), width: widht, height: widht)
                dayButton.layer.cornerRadius = CGFloat(Double(widht) / 5)
                dayButton.clipsToBounds = true
                dayButton.backgroundColor = .lightGray
                dayButton.setTitle("\(i)", for : UIControlState.normal)
                dayButton.setTitleColor(UIColor(red: 51/255, green: 102/255, blue: 153/255, alpha: 1), for: .normal)
                dayButton.setTitleColor(.lightGray, for: .selected)
                dayButton.setBackgroundColor(UIColor(red: 51/255, green: 102/255, blue: 153/255, alpha: 1), for: .selected)
                dayButton.tag = 100 + i
                dayButton.addTarget(self, action: #selector(pressButton), for: .touchDown)
                monthlyView.addSubview(dayButton)
            }
            column += 1
            if (i % 7) == 0 {
                row += 1
                column = 1
            }
        }
        monthlyView.frame.size.height = CGFloat(Double(widht) * 12.7)
    }

    
    // choose weekly day on add View
    @objc func pressButton(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
    }
    
    // turn of is need
    func installSwitchForDaily(howOften index:Int) {
        switch index {
        case 1: dailySwitch.setOn(true, animated: true)
                weeklySwitch.setOn(false, animated: true)
                monthlySwitch.setOn(false, animated: true)
        case 2: dailySwitch.setOn(false, animated: true)
                weeklySwitch.setOn(true, animated: true)
                monthlySwitch.setOn(false, animated: true)
        case 3: dailySwitch.setOn(false, animated: true)
                weeklySwitch.setOn(false, animated: true)
                monthlySwitch.setOn(true, animated: true)
        default:
            break
        }
        
    }
    // change enabled property if Add View is Active
    func enabledElementInVC(is isEnabled:Bool){
        pressSaveButton.isEnabled = isEnabled
        pressCancelButton.isEnabled = isEnabled
        nameTextField.isEnabled = isEnabled
        noteTExtField.isEnabled = isEnabled
        infoToNoteSegmentControl.isEnabled = isEnabled
        countTimesStepperOutlet.isEnabled = isEnabled
        weeklyLabel.isEnabled = isEnabled
        monthlyLabel.isEnabled = isEnabled
        weeklySwitch.isEnabled = isEnabled
        monthlySwitch.isEnabled = isEnabled
        dailySwitch.isEnabled = isEnabled
        notificationSwitch.isEnabled = isEnabled
    }
    // choose 1 from 3
    @IBAction func actionDailySwitch(_ sender: UISwitch) {
        installSwitchForDaily(howOften: 1)
    }
    
    // choose 2 from 3
    @IBAction func actionWeeklySwitch(_ sender: UISwitch) {
        installSwitchForDaily(howOften: 2)
        weeklyView.isHidden = false
        enabledElementInVC(is: false)
        createElementForWeeklyView()
    }
    
    // choose 3 from 3
    @IBAction func actionMonthlySwitch(_ sender: UISwitch) {
        installSwitchForDaily(howOften: 3)
        monthlyView.isHidden = false
        enabledElementInVC(is: false)
        createElementForMonthlyView()
    }
    
    func showAlertWith(message:String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Хорошо", style: .cancel, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    // close WeeklyView
    @IBAction func readyWeeklyViewButton(_ sender: UIButton) {
        var isSelected = false
        var numberWeeklyDay = 1
        while numberWeeklyDay != 8 { // I known bad
            if let newButton = self.view.viewWithTag(numberWeeklyDay) as? UIButton {
                if newButton.isSelected {
                    isSelected = true
                    print(numberWeeklyDay)
                }
            }
            if isSelected {
                numberWeeklyDay = 8
            } else {
                numberWeeklyDay += 1
            }
        }
        if !isSelected {
            showAlertWith(message: "Не выбран день недели")
        }
        else {
            enabledElementInVC(is: true)
            weeklyView.isHidden = true
        }
    }
    
    @IBAction func readyMonthlyViewButton(_ sender: UIButton) {
        // need code
        var isSelected = false
        var numberDay = 1
        while numberDay != 32 { // I known bad
            if let newButton = self.view.viewWithTag(100 + numberDay) as? UIButton {
                if newButton.isSelected {
                    isSelected = true
                }
            }
            if isSelected {
                numberDay = 32
            } else {
                numberDay += 1
            }
        }
        if !isSelected {
            showAlertWith(message: "Не выбраны даты")
        }
        else {
            enabledElementInVC(is: true)
            monthlyView.isHidden = true
        }
    }
    
}

// set Color in backGround if button is Selected = true
extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}
