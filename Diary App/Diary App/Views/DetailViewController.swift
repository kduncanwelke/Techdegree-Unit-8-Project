//
//  DetailViewController.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/18/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var badMoodButton: UIButton!
    @IBOutlet weak var okMoodButton: UIButton!
    @IBOutlet weak var goodMoodButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        journalTextView.delegate = self
        titleTextField.delegate = self
        
        configureView()
    }

    var detailItem: NSManagedObject? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // MARK: Custom functions
    
    func configureView() {
        journalTextView.text = "Start typing . . ."
        journalTextView.textColor = UIColor.lightGray
        
        titleTextField.text = "Enter title . . ."
        titleTextField.textColor = UIColor.darkGray
        
        dateLabel.text = setDate()
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
        let managedContext = CoreDataManager(modelName: "JournalEntry").managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "JournalEntry", in: managedContext)
        let newEntry = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        newEntry.setValue(titleTextField.text, forKey: "title")
        newEntry.setValue(journalTextView.text, forKey: "entry")
        newEntry.setValue(dateLabel.text, forKey: "timestamp")
        
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
    
}

