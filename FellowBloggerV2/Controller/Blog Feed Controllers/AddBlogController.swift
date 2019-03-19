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

    @IBOutlet weak var postBarButton: UIBarButtonItem!
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
        postBarButton.isEnabled = false
        dismiss(animated: true, completion: nil)
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
