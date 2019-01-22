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
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 28
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 300
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Start typing . . ."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.darkGray {
            textField.text = nil
            textField.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text?.isEmpty else { return }
        if text {
            textField.text = "Enter title . . ."
            textField.textColor = UIColor.darkGray
        } else {
            return
        }
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
            
            do {
                try managedContext.save()
            } catch {
                print("Failed to save")
            }
            return
        }
        
        selection.title = titleTextField.text
        selection.entry = journalTextView.text
        selection.timestamp = dateLabel.text
        selection.location = locationButton.titleLabel?.text
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to save")
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
        case 1:
            badMoodButton.isSelected = false
            okMoodButton.isSelected = true
            goodMoodButton.isSelected = false
        case 2:
            badMoodButton.isSelected = false
            okMoodButton.isSelected = false
            goodMoodButton.isSelected = true
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

