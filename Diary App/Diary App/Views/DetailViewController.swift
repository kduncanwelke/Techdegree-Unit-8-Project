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

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var badMoodButton: UIButton!
    @IBOutlet weak var okMoodButton: UIButton!
    @IBOutlet weak var goodMoodButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var usedCharactersLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    var detailItem: JournalEntry?
    var reaction: Reaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // delegates
        journalTextView.delegate = self
        titleTextField.delegate = self
        imagePicker.delegate = self
        
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
        if let characterCount = selection.entry?.count {
            usedCharactersLabel.text = "\(characterCount)/300"
        }
        dateLabel.text = selection.timestamp
        locationButton.setTitle(selection.location ?? "Add location . . .", for: .normal)
        
        selectReaction(reactionString: selection.reaction)
        
        guard let data = selection.imageData else { return }
        imageButton.setBackgroundImage(UIImage(data: data), for: .normal)
        roundButton()
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
            
            if imageButton.backgroundImage(for: .normal) != UIImage(named: "icn_noimage") {
                let data = imageButton.backgroundImage(for: .normal)?.pngData()
                guard let imageData = data else { return }
                newEntry.imageData = imageData as Data
            }
            
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
        
        if imageButton.backgroundImage(for: .normal) != UIImage(named: "icn_noimage") {
            let data = imageButton.backgroundImage(for: .normal)?.pngData()
            guard let imageData = data else { return }
            selection.imageData = imageData as Data
        }
        
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
    
    func roundButton() {
        // make image round
        imageButton.layer.cornerRadius = imageButton.frame.height / 2
        imageButton.clipsToBounds = true
    }
    
    // image picker functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let percentToReduce = (pickedImage.size.width / imageButton.frame.width) / 100
           
            let resizedImage = pickedImage.resize(toPercent: percentToReduce)
            
            imageButton.setBackgroundImage(resizedImage, for: .normal)
            
            roundButton()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnAfterSave" {
            saveEntry()
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
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

