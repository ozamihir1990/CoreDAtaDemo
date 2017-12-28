//
//  ViewController.swift
//  CoreDAtaDemo
//
//  Created by Mihir Oza on 12/21/17.
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
        self.fetchData()
        // For fetch data.
        //1
        /*guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
         return
         }
         let managedContext = appDelegate.persistentContainer.viewContext
         //2
         let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
         //3
         do {
         people = try managedContext.fetch(fetchRequest)
         } catch let error as NSError {
         print("Could not fetch. \(error), \(error.userInfo)")
         }*/
    }
    func fetchData()  {
        // For fetch data.
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: nil, preferredStyle: .alert)
        
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
    // Save Record.
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
    func updateData(name: String,age: Double, oldName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        do {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
            fetchRequest.predicate = NSPredicate(format: "name = %@", oldName)
            
            let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [NSManagedObject]
            if fetchResults?.count != 0{
                let managedObject = fetchResults![0]
                managedObject.setValue(name, forKey: "name")
                managedObject.setValue(age, forKey: "age")
                
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Update failed: \(error.localizedDescription)")
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
        
        let rect = CGRect(x: 5, y: 5, width: 50, height: 50)
        let cellImg : UIImageView = UIImageView(frame: rect)
       
        cellImg.image = UIImage(named: "ico")
        cell.imageView?.image = cellImg.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let person = self.people[indexPath.row]
            let alert = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
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
                self.updateData(name: nameToSave, age: age, oldName: String(describing: person.value(forKeyPath: "name") as! String))
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alert.addTextField{(textField : UITextField!) -> Void in
                textField.placeholder = "Name"
                textField.text = String(describing: person.value(forKeyPath: "name") as! String)
            }
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Age"
                textField.text = String(describing: person.value(forKeyPath: "age") as! integer_t)
            }
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
        edit.backgroundColor = UIColor.lightGray
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let person = self.people[indexPath.row]
            managedContext.delete(person)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error While Deleting Record: \(error.userInfo)")
            }
            self.fetchData()
            tableView.reloadData()
        }
        delete.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    //    func tableView(_ tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) {
    //        let cell = self.tableView.cellForRow(at: indexPath as IndexPath)
    //        NSLog("did select and the text is \(String(describing: cell?.textLabel?.text))")
    //    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let cell = tableView.cellForRow(at: indexPath)!
    //        let person = people[indexPath.row]
    //        cell.accessoryType = UITableViewCellAccessoryType.none
    //        NSLog("select name is \(String(describing: person.value(forKeyPath: "name") as! String))")
    //        NSLog("select age is \(String(describing: person.value(forKeyPath: "age") as! integer_t))")
    //    }
}
