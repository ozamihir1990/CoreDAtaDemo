//
//  ViewController.swift
//  CoreDAtaDemo
//
//  Created by prasanna on 12/21/17.
//  Copyright © 2017 Ashadeep. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // For fetch data.
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //3
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?[0],
                let nameToSave = textField.text else {
                    return
            }
            guard let textfield1 = alert.textFields?[1],
                let age = Double(textfield1.text!) else {
                    return
            }
            //self.save(name: nameToSave)
            self.save(name: nameToSave, age: age)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField{(textField : UITextField!) -> Void in
            textField.placeholder = "Name"
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Age"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    // for add data.
    func save(name: String,age: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // 1
        let  managedContext = appDelegate.persistentContainer.viewContext
        //2
        let entity  = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        //3
        person.setValue(name, forKey: "name")
        person.setValue(age, forKey: "age")
        //4
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let person = people[indexPath.row]
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
            cell.textLabel?.text = person.value(forKeyPath: "name") as? String
            cell.detailTextLabel?.text = String (describing: person.value(forKeyPath: "age") as! integer_t)
            return cell
    }
    func tableView(_ tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath)
        NSLog("did select and the text is \(String(describing: cell?.textLabel?.text))")
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let person = people[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.none
        NSLog("select name is \(String(describing: person.value(forKeyPath: "name") as! String))")
        NSLog("select age is \(String(describing: person.value(forKeyPath: "age") as! integer_t))")
    }
}
