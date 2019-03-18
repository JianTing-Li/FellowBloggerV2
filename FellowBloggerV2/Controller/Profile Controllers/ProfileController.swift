//
//  ProfileController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/14/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var profileBlogTableView: UITableView!
    
    private lazy var profileHeaderView: ProfileHeaderView = {
        let headerView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        return headerView
    }()
    
    private var authservice = AppDelegate.authservice
    
    private var blogs = [Blog]() {
        didSet {
            DispatchQueue.main.async {
                self.profileBlogTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileHeaderView.delegate = self
        configureTableView()
        fetchUserBlogs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateProfileUI()
    }
    
    private func updateProfileUI() {
//        guard let user = authservice.getCurrentUser() else {
//            print("no logged user")
//            return
//        }
//        DBService.fetchUser(userId: user.uid) { [weak self] (error, user) in
//            if let _ = error {
//                self?.showAlert(title: "Error fetching account info", message: error?.localizedDescription)
//            } else if let user = user {
//                self?.profileHeaderView.displayNameLabel.text = "@" + user.displayName
//                guard let photoURL = user.photoURL,
//                    !photoURL.isEmpty else {
//                        return
//                }
//                self?.profileHeaderView.profileImageView.kf.setImage(with: URL(string: photoURL), placeholder: #imageLiteral(resourceName: "placeholder-image.png"))
//            }
//        }
    }
    
    // fetch only user's dishes (Query: search  / filter)
    private func fetchUserBlogs() {
//        guard let user = authservice.getCurrentUser() else {
//            print("no logged user")
//            return
//        }
//        // https://firebase.google.com/docs/firestore/query-data/queries?authuser=1
//        // add a "Listener" when we want the cloud data to be automatically updated to any changes (add, delete, edit) & update our data locally (app)
//        let _ = DBService.firestoreDB
//            .collection(DishesCollectionKeys.CollectionKey)
//            .whereField(DishesCollectionKeys.UserIdKey, isEqualTo: user.uid)
//            .addSnapshotListener { [weak self] (snapshot, error) in
//                if let error = error {
//                    self?.showAlert(title: "Error fetching dishes", message: error.localizedDescription)
//                } else if let snapshot = snapshot {
//                    self?.dishes = snapshot.documents.map { Dish(dict: $0.data()) }
//                        .sorted { $0.createdDate.date() > $1.createdDate.date() }
//                }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Show Edit Profile" {
//            guard let navController = segue.destination as? UINavigationController,
//                let editProfileVC = navController.viewControllers.first as? EditProfileViewController
//                else {
//                    fatalError("editProfileVC not found")
//            }
//            editProfileVC.profileImage = profileHeaderView.profileImageView.image
//            editProfileVC.displayName = profileHeaderView.displayNameLabel.text
//        } else if segue.identifier == "Show Dish Details" {
//            guard let indexPath = sender as? IndexPath,
//                let cell = tableView.cellForRow(at: indexPath) as? DishCell,
//                let dishDVC = segue.destination as? DishDetailViewController else {
//                    fatalError("cannot segue to dishDVC")
//            }
//            let dish = dishes[indexPath.row]
//            dishDVC.displayName = cell.displayNameLabel.text
//            dishDVC.dish = dish
//        }
    }

}


extension ProfileController: UITableViewDataSource, UITableViewDelegate {
    private func configureTableView() {
        profileBlogTableView.tableHeaderView = profileHeaderView
        profileBlogTableView.dataSource = self
        profileBlogTableView.delegate = self
        profileBlogTableView.register(UINib(nibName: "BlogCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "BlogCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath) as? DishCell else {
//            fatalError("DishCell not found")
//        }
//        let dish = dishes[indexPath.row]
//        cell.selectionStyle = .none
//        cell.countryLabel.text = dish.country
//        cell.dishDescriptionLabel.text = dish.dishDescription
//        cell.displayNameLabel.text = ""
//        cell.dishImageView.kf.setImage(with: URL(string: dish.imageURL), placeholder: #imageLiteral(resourceName: "placeholder-image.png"))
//        return cell
        guard let cell = profileBlogTableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as? BlogCell else {
            fatalError("BlogCell not found")
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            performSegue(withIdentifier: "Show Dish Details", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

extension ProfileController: ProfileHeaderViewDelegate {
    func willSignOut(profileHeaderView: ProfileHeaderView) {
        authservice.signOutAccount()
    }
    
    func willEditProfile(profileHeaderView: ProfileHeaderView) {
//            performSegue(withIdentifier: "Show Edit Profile", sender: nil)
    }
}

// This goes in the BlogFeedController
//extension ProfileController: AuthServiceSignOutDelegate {
//    //  authservice.authservicesSignOutDelegate = self
//    //  private var listener: ListenerRegistration!
//    func didSignOutWithError(_ authservice: AuthService, error: Error) {
//        listener.remove()
//        showLoginView()
//        // bug visual bug stack is stacking (need to pop the VCS) --- maybe use a smaller project
//    }
//
//    func didSignOut(_ authservice: AuthService) {
//        showAlert(title: "Sign Out Error", message: "Unable to Sign out.")
//    }
//}
