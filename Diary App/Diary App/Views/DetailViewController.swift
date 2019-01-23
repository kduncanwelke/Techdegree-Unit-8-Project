//
//  DetailViewController.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/18/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var badMoodButton: UIButton!
    @IBOutlet weak var okMoodButton: UIButton!
    @IBOutlet weak var goodMoodButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var detailItem: JournalEntry?
    var reaction: Reaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        journalTextView.delegate = self
        titleTextField.delegate = self
        
        configureView()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: Custom functions
    
    func configureView() {
        guard let selection = detailItem else {
            journalTextView.text = "Start typing . . ."
            journalTextView.textColor = UIColor.lightGray
            
            titleTextField.text = "Enter title . . ."
            titleTextField.textColor = UIColor.darkGray
            
            dateLabel.text = setDate()
            return
        }
        
        titleTextField.text = selection.title
        journalTextView.text = selection.entry
        dateLabel.text = selection.timestamp
        locationButton.setTitle(selection.location ?? "Add location . . .", for: .normal)
        
        selectReaction(reactionString: selection.reaction)
    }
    
    
    func setDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let currentDate = Date()
        let dateString = formatter.string(from: currentDate)
        return dateString
    }
    
    func saveEntry() {
         let managedContext = CoreDataManager.shared.managedObjectContext
        
        guard let selection = detailItem else {
            let newEntry = JournalEntry(context: managedContext)
            
            newEntry.title = titleTextField.text
            newEntry.entry = journalTextView.text
            newEntry.timestamp = dateLabel.text
            newEntry.location = locationButton.titleLabel?.text
            newEntry.reaction = reaction?.rawValue
            
            do {
                try managedContext.save()
            } catch {
                print("Failed to save")
            }
            return
        }
        
        selection.title = titleTextField.text
        selection.entry = journalTextView.text
        selection.timestamp = setDate()
        selection.location = locationButton.titleLabel?.text
        selection.reaction = reaction?.rawValue
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to save")
        }
    }
    
    func selectReaction(reactionString: String?) {
        guard let reaction = reactionString else { return }
        
        if reaction == Reaction.bad.rawValue {
            badMoodButton.isSelected = true
        } else if reaction == Reaction.ok.rawValue {
            okMoodButton.isSelected = true
        } else if reaction == Reaction.good.rawValue {
            goodMoodButton.isSelected = true
        } 
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnAfterSave" {
            saveEntry()
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func moodButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            badMoodButton.isSelected = true
            okMoodButton.isSelected = false
            goodMoodButton.isSelected = false
            
            reaction = Reaction.bad
        case 1:
            badMoodButton.isSelected = false
            okMoodButton.isSelected = true
            goodMoodButton.isSelected = false
            
            reaction = Reaction.ok
        case 2:
            badMoodButton.isSelected = false
            okMoodButton.isSelected = false
            goodMoodButton.isSelected = true
            
            reaction = Reaction.good
        default:
            break
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if titleTextField.text == nil || titleTextField.text == "Enter title . . ." {
            showAlert(title: "Missing information", message: "Please enter a title")
        } else if journalTextView.text == nil || journalTextView.text == "Start typing . . ." {
            showAlert(title: "Missing information", message: "Please enter some text for your journal entry")
        } else {
            performSegue(withIdentifier: "returnAfterSave", sender: Any?.self)
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        locationManager.requestLocation()
        
        lookUpCurrentLocation { geoLoc in
            self.locationButton.setTitle(geoLoc?.locality ?? "Unknown", for: .normal)
        }
    }
    
}

