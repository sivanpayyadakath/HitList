//
//  ViewController.swift
//  HitList
//
//  Created by Sivan.Payyadakath on 2019/05/15.
//  Copyright © 2019 Sivan.Payyadakath. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var names: [String] = []
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Names List"
//      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
//      fetching from core data store
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedView = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            try people = managedView.fetch(fetchRequest)
        } catch let error as NSError {
            print("couldnt fetch, \(error) \(error.userInfo)")
        }
        
    
        navigationItem.leftBarButtonItem = editButtonItem
    }


    
    @IBAction func addName(_ sender: Any) {
        let alertController = UIAlertController(title: "New Name", message: "Add a new Name", preferredStyle: .alert)
        
        alertController.addTextField()
        
        let okAction = UIAlertAction(title: "OK", style: .default){(action:UIAlertAction!) in
            print("Ok button tapped")
            
            guard let textField = alertController.textFields?.first else{
                return
            }
            if let nameToSave = textField.text{
                self.save(name: nameToSave)
                self.tableView.reloadData()
            }
            
            
        }
        
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("cancel button pressed")
        }
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func save(name: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("couldnt save\(error), \(error.userInfo)")
        }
    }
    

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            print("delete \(indexPath.row)")
            let m = people.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedView = appDelegate.persistentContainer.viewContext
        
            managedView.delete(m)

        }
    }
    
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
    
    
    
}
