//
//  MasterViewController.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/18/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
   var detailViewController: DetailViewController? = nil
   
   var journalEntries: [NSManagedObject] = []
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
      navigationItem.leftBarButtonItem = editButtonItem
      
      if let split = splitViewController {
         let controllers = split.viewControllers
         detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
      super.viewWillAppear(animated)
      
      let managedContext = CoreDataManager(modelName: "JournalEntry").managedObjectContext
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JournalEntry")
      
      do {
         journalEntries = try managedContext.fetch(fetchRequest)
         print(journalEntries[0])
      } catch let error as NSError {
         print("could not fetch, \(error), \(error.userInfo)")
      }
   }
   
   @objc
   func insertNewObject(_ sender: Any) {
      //objects.insert(NSDate(), at: 0)
      let indexPath = IndexPath(row: 0, section: 0)
      tableView.insertRows(at: [indexPath], with: .automatic)
   }
   
   // MARK: - Segues
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "showDetail" {
         if let indexPath = tableView.indexPathForSelectedRow {
            let entry = journalEntries[indexPath.row]
            print(journalEntries[1])
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem? = entry
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
         }
      }
   }
   
   // MARK: - Table View
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return journalEntries.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      
      let entry = journalEntries[indexPath.row]
      cell.textLabel?.text = entry.value(forKeyPath: "title") as? String
      return cell
   }
   
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
   }
   
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         //objects.remove(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .fade)
      } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
      }
   }
    
    @IBAction func writeButtonPressed(_ sender: Any) {
         performSegue(withIdentifier: "showDetail", sender: Any?.self)
    }
    
}

