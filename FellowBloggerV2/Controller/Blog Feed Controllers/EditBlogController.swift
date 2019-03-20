//
//  EditBlogController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class EditBlogController: UIViewController {
    
    @IBOutlet weak var blogDescriptionTextView: UITextView!
    
    var blog: Blog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        blogDescriptionTextView.text = blog.blogDescription
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateBlogButtonPressed(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let newBlogDescription = blogDescriptionTextView.text, !newBlogDescription.isEmpty else {
            showAlert(title: "Missing Fields", message: "Blog Description is Required")
            return
        }
        // Updating Firebase
        // step 1 --> get the database reference
        // step 2 --> get the collection
        // step 3 --> pass the document id
        // step 4 --> update fields as necessary
        DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId)
            .updateData([BlogsCollectionKeys.BlogDescriptionKey : newBlogDescription]) { [weak self] (error) in
                if let error = error {
                    self?.showAlert(title: "Editing Error", message: error.localizedDescription)
                } else {
                    // setting up unwind segue
                    // Step 2: implement perform segue in view controller unwinding from
                    // Step 3: set segue identifier in storyboard
                    // control drag form "yellow" storyboard icon over to "exit" icon and select
                    // "undwindFrom... function" that refers to the function in the first view controller
                    self?.performSegue(withIdentifier: "Unwind From Edit BlogDescription", sender: self)
                }
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}
