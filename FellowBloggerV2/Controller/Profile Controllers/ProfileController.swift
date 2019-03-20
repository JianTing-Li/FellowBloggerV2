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
    
    private var blogger: Blogger?
    private var userBlogs = [Blog]() {
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
        guard let blogger = authservice.getCurrentUser() else {
            print("No logged user")
            return
        }
        DBService.getBlogger(userId: blogger.uid) { [weak self] (error, blogger) in
            if let error = error {
                self?.showAlert(title: "Error fet hing account info", message: error.localizedDescription)
            } else if let blogger = blogger {
                self?.profileHeaderView.bioLabel.text = blogger.bio ?? ""
                self?.profileHeaderView.nameLabel.text = blogger.fullName
                self?.profileHeaderView.displayNameLabel.text = "@" + blogger.displayName
                if let profileImageURL = blogger.photoURL {
                    self?.profileHeaderView.profieImageView.kf.indicatorType = .activity
                    self?.profileHeaderView.profieImageView.kf.setImage(with: URL(string: profileImageURL), placeholder: #imageLiteral(resourceName: "placeholder.png"))
                }
                if let coverPhotoURL = blogger.coverImageURL {
                    self?.profileHeaderView.coverPhotoImageView.kf.indicatorType = .activity
                    self?.profileHeaderView.coverPhotoImageView.kf.setImage(with: URL(string: coverPhotoURL), placeholder: #imageLiteral(resourceName: "placeholder.png"))
                }
            }
        }
    }
    
    // fetch only user's dishes (Query: search  / filter)
    private func fetchUserBlogs() {
        guard let user = authservice.getCurrentUser() else {
            print("no logged user")
            return
        }
        // https://firebase.google.com/docs/firestore/query-data/queries?authuser=1
        // add a "Listener" when we want the cloud data to be automatically updated to any changes (add, delete, edit) & update our data locally (app)
        let _ = DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .whereField(BlogsCollectionKeys.BloggerIdKey, isEqualTo: user.uid)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    self?.showAlert(title: "Error fetching blogs", message: error.localizedDescription)
                } else if let snapshot = snapshot {
                    self?.userBlogs = snapshot.documents.map { Blog(dict: $0.data()) }
                        .sorted { $0.createdDate.date() > $1.createdDate.date() }
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Blog Details" {
            guard let indexPath = sender as? IndexPath,
                let blogDVC = segue.destination as? BlogFeedDetailController else {
                    fatalError("Cannot Segue to BlogDVC")
            }
            let selectedBlog = userBlogs[indexPath.row]
            blogDVC.blog = selectedBlog
        } else if segue.identifier == "Show Edit Profile VC" {
            
        }
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
        profileBlogTableView.register(UINib(nibName: "BlogCell", bundle: nil), forCellReuseIdentifier: "BlogCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userBlogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = profileBlogTableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as? BlogCell else {
            fatalError("BlogCell not found")
        }
        let selectedBlog = userBlogs[indexPath.row]
        cell.configureCell(blog: selectedBlog)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Blog Details", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.BlogCellHeight
    }
}

extension ProfileController: ProfileHeaderViewDelegate {
    func willSignOut(profileHeaderView: ProfileHeaderView) {
        authservice.signOutAccount()
        showLoginView()
    }
    
    func willEditProfile(profileHeaderView: ProfileHeaderView) {
        performSegue(withIdentifier: "Show Edit Profile VC", sender: nil)
    }
}
