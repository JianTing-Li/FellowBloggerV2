//
//  AddBlogController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit
import Toucan

class AddBlogController: UIViewController {

    @IBOutlet weak var blogDescriptionTextView: UITextView!
    @IBOutlet weak var blogImageView: UIImageView!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    private var selectedImage:UIImage?
    private var authservice = AppDelegate.authservice
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextView()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        // disable right away so there won't be multiple pressed
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let blogDescription = blogDescriptionTextView.text,
            !blogDescription.isEmpty,
            let imageData = selectedImage?.jpegData(compressionQuality: 1.0) else {
                print("Missing Fields")
                return
        }
        guard let user = authservice.getCurrentUser() else {
            print("no logged user")
            return
        }
        
        // create a documentId for each dish
        // 1: generate a document id from firebase
        // 2: this will be the unique id to retrieve the document
        let docRef = DBService.firestoreDB.collection(BlogsCollectionKeys.CollectionKey).document()
        
        StorageService.postImage(imageData: imageData,
                                 imageName: Constants.BlogImagePath + "\(user.uid)/\(docRef.documentID))") { [weak self] (error, imageURL) in
                                    if let error = error {
                                        print("Fail to post image with error: \(error.localizedDescription)")
                                        self?.navigationItem.rightBarButtonItem?.isEnabled = true
                                    } else if let imageURL = imageURL {
                                        print("Image posted & received imageURL -> post blog to database: \(imageURL)")
                                        let blog = Blog(createdDate: Date.getISOTimestamp(),
                                                        bloggerId: user.uid,
                                                        imageURL: imageURL.absoluteString,
                                                        blogDescription: blogDescription,
                                                        documentId: docRef.documentID)
                                        DBService.postBlog(blog: blog, completion: { (error) in
                                            if let error = error {
                                                self?.showAlert(title: "Posting Blog Error", message: error.localizedDescription)
                                            } else {
                                                self?.showAlert(title: "Blog Posted", message: nil)
                                                self?.dismiss(animated: true, completion: nil)
                                            }
                                        })
                                        self?.navigationItem.rightBarButtonItem?.isEnabled = true
                                    }
        }
    }
}

// initial configurations
extension AddBlogController {
    private func configureTextView() {
        configureInputAccessoryView()
        blogDescriptionTextView.delegate = self
        blogDescriptionTextView.textColor = .lightGray
        blogDescriptionTextView.text = Constants.BlogDescriptionPlaceholder
    }
    
    private func configureInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let cameraBarItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonPressed))
        let photoLibraryBarItem = UIBarButtonItem(image: UIImage(named: "icons8-photoLibrary"), style: .plain, target: self, action: #selector(photoLibraryButtonPressed))
        let flexibleSpaceBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [cameraBarItem, flexibleSpaceBarItem, photoLibraryBarItem]
        blogDescriptionTextView.inputAccessoryView = toolbar
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraBarItem.isEnabled = false
        }
    }

    @objc func cameraButtonPressed() {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }

    @objc func photoLibraryButtonPressed() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
}


extension AddBlogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("Original image is nil")
            return
        }
        // resize image to reduce memory footprint while app is running
        // if not the app will terminate if memory run low
        let resizedImage = Toucan(image: originalImage).resize(CGSize(width: 500, height: 500))
        selectedImage = resizedImage.image
        blogImageView.image = resizedImage.image
        dismiss(animated: true, completion: nil)
    }
}


extension AddBlogController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.BlogDescriptionPlaceholder {
            textView.textColor = .black
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = .lightGray
            textView.text = Constants.BlogDescriptionPlaceholder
        }
    }
}
