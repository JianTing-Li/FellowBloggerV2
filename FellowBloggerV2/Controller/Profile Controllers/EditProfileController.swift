//
//  EditProfileController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

enum ProfileComponent: CaseIterable {
    case firstName
    case lastName
    case userName
    case bio
}

class EditProfileController: UIViewController {
    
    @IBOutlet weak var editProfileTableView: UITableView!
    
    public var blogger: Blogger! // only use for initial setup
    
    // profileComponents & profileComponentsArray are used through the profile update
    private var profileComponents: [ProfileComponent: String] = [
        .firstName : "",
        .lastName : "",
        .userName : "",
        .bio : ""
    ] {
        didSet {
            DispatchQueue.main.async {
                self.editProfileTableView.reloadData()
            }
        }
    }
    private var profileComponentsArray: [ProfileComponent] = [.firstName,
                                                              .lastName,
                                                              .userName,
                                                              .bio ]
    
//    private var selectedImage: UIImage?
//    private lazy var imagePickerController: UIImagePickerController = {
//        let ip = UIImagePickerController()
//        ip.delegate = self
//        return ip
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileComponents()
        editProfileTableView.dataSource = self
        //setup uipickerview
    }
    
    private func setProfileComponents() {
        profileComponents[.firstName] = blogger.firstName
        profileComponents[.lastName] = blogger.lastName
        profileComponents[.userName] = blogger.displayName
        profileComponents[.bio] = blogger.bio
    }
    
    
    @IBAction func changeProfileImgButtonPressed(_ sender: CircularButton) {
//        var actionTitles = [String]()
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            actionTitles = ["Photo Library", "Camera"]
//        } else {
//            actionTitles = ["Photo Library"]
//        }
//        showActionSheet(title: nil, message: nil, actionTitles: actionTitles, handlers: [{ [unowned self] photoLibraryAction in
//            self.imagePickerController.sourceType = .photoLibrary
//            self.present(self.imagePickerController, animated: true)
//            }, { cameraAction in
//                self.imagePickerController.sourceType = .camera
//                self.present(self.imagePickerController, animated: true)
//            }
//            ])
    }
    
    @IBAction func changeCoverImgButtonPressed(_ sender: RoundedButton) {
        
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: UIBarButtonItem) {
//        navigationItem.rightBarButtonItem?.isEnabled = false
//        guard let imageData = selectedImage?.jpegData(compressionQuality: 1.0),
//            let user = authservice.getCurrentUser(),
//            let displayName = displayNameTextField.text,
//            !displayName.isEmpty else {
//                showAlert(title: "Missing Fields", message: "A photo and username are Required")
//                return
//        }
//        StorageService.postImage(imageData: imageData, imageName: Constants.ProfileImagePath + user.uid) { [weak self] (error, imageURL) in
//            if let error = error {
//                self?.showAlert(title: "Error Saving Photo", message: error.localizedDescription)
//            } else if let imageURL = imageURL {
//                // update auth user and user db document
//                let request = user.createProfileChangeRequest()
//                request.displayName = displayName
//                request.photoURL = imageURL
//                request.commitChanges(completion: { (error) in
//                    if let error = error {
//                        self?.showAlert(title: "Error Saving Account Info", message: error.localizedDescription)
//                    }
//                })
//                DBService.firestoreDB
//                    .collection(NDUsersCollectionKeys.CollectionKey)
//                    .document(user.uid)
//                    .updateData([NDUsersCollectionKeys.PhotoURLKey    : imageURL.absoluteString,
//                                 NDUsersCollectionKeys.DisplayNameKey : displayName
//                        ], completion: { (error) in
//                            if let error = error {
//                                self?.showAlert(title: "Error Saving Account Info", message: error.localizedDescription)
//                            }
//                    })
//                self?.dismiss(animated: true)
//                self?.navigationItem.rightBarButtonItem?.isEnabled = true
//            }
//        }
    }
    
    @IBAction func DismissButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func unwindFromBioDetailView(segue: UIStoryboardSegue) {
        let editBioDetailVC = segue.source as! EditBioDetailController
        profileComponents[.bio] = editBioDetailVC.bioTextView.text
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Edit Bio Details" {
            guard let bioDetailVC = segue.destination as? EditBioDetailController else { fatalError("Cannot Segue to bioDetailVC") }
            if let userBio = profileComponents[.bio], !userBio.isEmpty {
                bioDetailVC.textViewText = userBio
            } else {
                bioDetailVC.textViewText = Constants.userBioTextViewPlaceholder
            }
        }
    }
}

extension EditProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileComponentsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentProfileComponent = profileComponentsArray[indexPath.row]
        if currentProfileComponent == .bio {
            let cell = editProfileTableView.dequeueReusableCell(withIdentifier: "ProfileBioCell", for: indexPath)
            cell.textLabel?.text = "Bio"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = profileComponents[.bio]
            return cell
        } else {
            guard let cell = editProfileTableView.dequeueReusableCell(withIdentifier: "ProfileEditCell", for: indexPath) as? ProfileEditCell else {
                fatalError("")
            }
            cell.contentTextField.delegate = self
            cell.configureCell(profileComponent: currentProfileComponent, profileComponents: profileComponents, tag: indexPath.row)
            return cell
        }
    }
}


extension EditProfileController: UITextFieldDelegate {
    // TODO: dismiss keyboard and update the profileComponents
}

//extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
//            print("original image not available")
//            return
//        }
//        let size = CGSize(width: 500, height: 500)
//        let resizedImage = Toucan.Resize.resizeImage(originalImage, size: size)
//        selectedImage = resizedImage
//        profileImageViewButton.setImage(resizedImage, for: .normal)
//        dismiss(animated: true)
//    }
//}
