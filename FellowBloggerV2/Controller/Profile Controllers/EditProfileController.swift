//
//  EditProfileController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit
import Toucan

enum ProfileComponent: String, CaseIterable {
    case firstName = "FirstName"
    case lastName = "LastName"
    case userName = "Username"
    case bio
}

private enum ImageEditingState {
    case profileImageEditing
    case coverImageEditing
}

private enum ImageState {
    case profileImage
    case coverImage
}

class EditProfileController: UIViewController {
    
    @IBOutlet weak var editProfileTableView: UITableView!
    @IBOutlet weak var profileImageButton: CircularButton!
    @IBOutlet weak var profileCoverImageButton: RoundedButton!
    
    private var authservice = AppDelegate.authservice
    public var blogger: Blogger! // only use for initial setup
    
    // profileComponents & profileComponentsArray are used through the profile update
    private var profileComponents: [ProfileComponent: String] = [
        .firstName : "",
        .lastName : "",
        .userName : "",
        .bio : ""
    ]

    private var profileComponentsArray: [ProfileComponent] = [.firstName,
                                                              .lastName,
                                                              .userName,
                                                              .bio ]
    
    private var selectedProfileImage: UIImage?
    private var selectedCoverImage: UIImage?
    
    private var imageEditingState: ImageEditingState?
    
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editProfileTableView.dataSource = self
        profileImageButton.kf.setImage(with: URL(string: blogger.photoURL ?? ""), for: .normal, placeholder: #imageLiteral(resourceName: "placeholder.png"))
        profileCoverImageButton.kf.setImage(with: URL(string: blogger.coverImageURL ?? ""), for: .normal, placeholder: #imageLiteral(resourceName: "placeholder.png"))
        setProfileComponents()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        editProfileTableView.reloadData()
    }
    
    
    private func setProfileComponents() {
        profileComponents[.firstName] = blogger.firstName
        profileComponents[.lastName] = blogger.lastName
        profileComponents[.userName] = blogger.displayName
        profileComponents[.bio] = blogger.bio
    }
    
    
    @IBAction func changeProfileImgButtonPressed(_ sender: CircularButton) {
        imageEditingState = .profileImageEditing
        setupAndPresentPickerController()
    }
    
    @IBAction func changeCoverImgButtonPressed(_ sender: RoundedButton) {
        imageEditingState = .coverImageEditing
        setupAndPresentPickerController()
    }
    
    // TODO: Study this function of code later
    private func setupAndPresentPickerController() {
        var actionTitles = [String]()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionTitles = ["Photo Library", "Camera"]
        } else {
            actionTitles = ["Photo Library"]
        }
        showActionSheet(title: nil, message: nil, actionTitles: actionTitles, handlers: [{ [unowned self] photoLibraryAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
            }, { cameraAction in
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true)
            }
            ])
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let user = authservice.getCurrentUser(), !(profileComponents[.userName]?.isEmpty)! else {
            showAlert(title: "Missing Fields", message: "Username is Required")
            return
        }
        
        var imageURLs = [ImageState : String]()
        var imageCalls = 0 {
            didSet {
                if imageCalls == 2 {
                    DBService.firestoreDB
                        .collection(BloggersCollectionKeys.CollectionKey)
                        .document(user.uid)
                        .updateData([BloggersCollectionKeys.PhotoURLKey : imageURLs[.profileImage] ?? "",
                                     BloggersCollectionKeys.CoverImageURLKey : imageURLs[.coverImage] ?? "",
                                     BloggersCollectionKeys.FirstNameKey : profileComponents[.firstName] ?? ProfileComponent.firstName.rawValue,
                                     BloggersCollectionKeys.LastNameKey : profileComponents[.lastName] ?? ProfileComponent.lastName.rawValue,
                                     BloggersCollectionKeys.DisplayNameKey : profileComponents[.userName]!,
                                     BloggersCollectionKeys.BioKey : profileComponents[.bio] ?? ""
                        ]) { [weak self] (error) in
                            if let error = error {
                                self?.showAlert(title: "Error Saving Account Info", message: error.localizedDescription)
                            }
                            self?.dismiss(animated: true, completion: nil)
                            self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            }
        }
       
    
        if let profileImageData = selectedProfileImage?.jpegData(compressionQuality: 1.0) {
            StorageService.postImage(imageData: profileImageData, imageName: Constants.ProfileImagePath + user.uid) { [weak self] (error, profileImageURL) in
                if let error = error {
                    self?.showAlert(title: "Error Saving Profile Photo", message: error.localizedDescription)
                } else if let profileImageURL = profileImageURL {
                    imageURLs[.profileImage] = profileImageURL.absoluteString
                }
                imageCalls += 1
            }
        } else { imageCalls += 1 }
        if let profileCoverImageData = selectedCoverImage?.jpegData(compressionQuality: 1.0) {
            StorageService.postImage(imageData: profileCoverImageData, imageName: Constants.ProfileCoverImagePath + user.uid) { [weak self] (error, profileCoverImageURL) in
                if let error = error {
                    self?.showAlert(title: "Error Saving Profile Photo", message: error.localizedDescription)
                } else if let profileCoverImageURL = profileCoverImageURL {
                    imageURLs[.coverImage] = profileCoverImageURL.absoluteString
                }
                imageCalls += 1
            }
        } else { imageCalls += 1 }
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        switch textField.tag {
        case 0:  // first name
            profileComponents[.firstName] = text + string
            print(profileComponents[.firstName] ?? "nil")
        case 1:  // last name
            profileComponents[.lastName] = text + string
            print(profileComponents[.lastName] ?? "nil")
        case 2:  // username
            profileComponents[.userName] = text + string
            print(profileComponents[.userName] ?? "nil")
        default:
            break
        }
        return true
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("original image not available")
            return
        }
        let size = CGSize(width: 500, height: 500)
        let resizedImage = Toucan.Resize.resizeImage(originalImage, size: size)
        switch imageEditingState {
        case .profileImageEditing?:
            selectedProfileImage = resizedImage
            profileImageButton.setImage(resizedImage, for: .normal)
        case .coverImageEditing?:
            selectedCoverImage = resizedImage
            profileCoverImageButton.setImage(resizedImage, for: .normal)
        default:
            break
        }
        dismiss(animated: true)
    }
}
