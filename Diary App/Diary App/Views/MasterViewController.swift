//
//  MasterViewController.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/18/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData
import Photos

class MasterViewController: UITableViewController, UISearchControllerDelegate {
   
   // MARK: Variables
   
   var detailViewController: DetailViewController? = nil
   var journalEntries: [JournalEntry] = []
   let searchController = UISearchController(searchResultsController: nil)
   var searchResults = [JournalEntry]()
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
      navigationItem.leftBarButtonItem = editButtonItem
      
      if let split = splitViewController {
         let controllers = split.viewControllers
         detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
      }
      
      // search setup
      searchController.delegate = self
      searchController.searchResultsUpdater = self
      searchController.obscuresBackgroundDuringPresentation = false
      searchController.searchBar.placeholder = "Type to search . . ."
      navigationItem.searchController = searchController
      navigationItem.hidesSearchBarWhenScrolling = false
   }
   
   // fetch data to prepare for display
   override func viewWillAppear(_ animated: Bool) {
      clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
      super.viewWillAppear(animated)
      
      self.definesPresentationContext = true

      let managedContext = CoreDataManager.shared.managedObjectContext
      let fetchRequest = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
      
      do {
         journalEntries = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
         print("could not fetch, \(error), \(error.userInfo)")
      }
   }
   
   @objc
   func insertNewObject(_ sender: Any) {
      let indexPath = IndexPath(row: 0, section: 0)
      tableView.insertRows(at: [indexPath], with: .automatic)
   }
   
   
   // MARK: Search bar configuration
   
   func searchBarIsEmpty() -> Bool {
      return searchController.searchBar.text?.isEmpty ?? true
   }
   
   // return search results based on title and entry body text
   func filterSearch(_ searchText: String) {
      searchResults = journalEntries.filter({(journal: JournalEntry) -> Bool in
         return journal.title!.lowercased().contains(searchText.lowercased()) || journal.entry!.lowercased().contains(searchText.lowercased())
      })
      tableView.reloadData()
   }
   
   func isFilteringBySearch() -> Bool {
      return searchController.isActive && !searchBarIsEmpty()
   }
   
   func searchBarCancelButtonClicked(searchBar: UISearchBar) {
      searchBar.endEditing(true)
   }
   
   // MARK: - Segues
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "showDetail" {
         if let indexPath = tableView.indexPathForSelectedRow {
            let entry: JournalEntry
            if isFilteringBySearch() {
               entry = searchResults[indexPath.row]
            } else {
               entry = journalEntries[indexPath.row]
            }
            
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = entry
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
      if isFilteringBySearch() {
         return searchResults.count
      } else {
         return journalEntries.count
      }
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath) as! JournalTableViewCell
      let entry: JournalEntry
      if isFilteringBySearch() {
         entry = searchResults[indexPath.row]
      } else {
         entry = journalEntries[indexPath.row]
      }
      
      cell.titleForEntry?.text = entry.title
      cell.entryText?.text = entry.entry
      cell.dateForEntry.text = entry.timestamp
      if let data = entry.imageData {
         cell.imageForEntry.image = UIImage(data: data)
      } else {
         cell.imageForEntry.image = UIImage(named: "icn_noimage") // return placeholder if no image
      }
      if let reaction = entry.reaction {
         cell.smilieImage.isHidden = false
         if reaction == Reaction.bad.rawValue {
            cell.smilieImage.image = UIImage(named: "icn_bad")
         } else if reaction == Reaction.ok.rawValue {
            cell.smilieImage.image = UIImage(named: "icn_average")
         } else if reaction == Reaction.good.rawValue {
            cell.smilieImage.image = UIImage(named: "icn_happy")
         }
      } else {
         cell.smilieImage.isHidden = true
      }
      
      
      cell.imageForEntry.layer.cornerRadius = cell.imageForEntry.frame.height / 2
      cell.imageForEntry.clipsToBounds = true
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
   }
   
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         if isFilteringBySearch() {
            
            let managedContext = CoreDataManager.shared.managedObjectContext
            managedContext.delete(searchResults[indexPath.row] as JournalEntry)
            
            do {
               try managedContext.save()
            } catch {
               print("Failed to save")
            }
            
            searchResults.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
         } else {
            
            let managedContext = CoreDataManager.shared.managedObjectContext
            managedContext.delete(journalEntries[indexPath.row] as JournalEntry)
            
            do {
               try managedContext.save()
            } catch {
               print("Failed to save")
            }
            
            journalEntries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
         }
      
      } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
      }
   }
   
   // MARK: Actions
    
    @IBAction func writeButtonPressed(_ sender: Any) {
         performSegue(withIdentifier: "showDetail", sender: Any?.self)
    }
    
}
