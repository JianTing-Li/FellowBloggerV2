//
//  EditProfileDetailController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class EditBioDetailController: UIViewController {
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var bioPlaceholder = Constants.userBioTextViewPlaceholder
    var textViewText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextView.delegate = self
        bioTextView.text = textViewText
        if bioTextView.text == bioPlaceholder { bioTextView.textColor = .lightGray }
    }

    @IBAction func saveBioButtonPressed(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        performSegue(withIdentifier: "Unwind From Edit Bio VC", sender: self)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension EditBioDetailController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == bioPlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = bioPlaceholder
        }
    }
}
