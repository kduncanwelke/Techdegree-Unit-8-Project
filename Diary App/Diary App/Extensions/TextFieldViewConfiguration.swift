//
//  TextFieldConfiguration.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

extension DetailViewController {
    // limit title length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 28
    }
    
    // limit journal entry length
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        usedCharactersLabel.text = "\(textView.text.count)/300"
        return changedText.count <= 300
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // reassign placeholder if empty
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
    
    // reassign placeholder if empty
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text?.isEmpty else { return }
        if text {
            textField.text = "Enter title . . ."
            textField.textColor = UIColor.darkGray
        } else {
            return
        }
    }
    
}
