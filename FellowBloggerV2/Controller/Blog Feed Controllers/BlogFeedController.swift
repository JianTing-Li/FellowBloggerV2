//
//  BlogFeedController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/13/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Toucan

class BlogFeedController: UIViewController {
    
    @IBOutlet weak var blogFeedTableView: UITableView!
    
    private var blogs = [Blog]() {
        didSet {
            DispatchQueue.main.async {
                self.blogFeedTableView.reloadData()
            }
        }
    }
    
    private var listener: ListenerRegistration!
    private var authservice = AppDelegate.authservice
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        blogFeedTableView.refreshControl = rc
        rc.addTarget(self, action: #selector(fetchAllBlogs), for: .valueChanged)
        return rc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        authservice.authservicesSignOutDelegate = self
        fetchAllBlogs()
    }
    
    private func configureTableView() {
        blogFeedTableView.dataSource = self
        blogFeedTableView.delegate = self
        blogFeedTableView.register(UINib(nibName: "BlogCell", bundle: nil), forCellReuseIdentifier: "BlogCell")
    }
    
    @objc private func fetchAllBlogs() {
//        // creating a listener
//        // 1. get database reference DBService.firestoreCB
//        // 2. which collection do you want to observe (listen) to?
//        // 3. add listener (addSnapshotListener)
        refreshControl.beginRefreshing()
        listener = DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
//            // always observes firebase in real-time for data changes
//            // [weak self] - closure list, breaks potential memory leals
//            // [weak self] - breaks strong retain cycles
//            // use [weak self] when closure may be around longer than view controller
//            // use [unowned self] when view controller is guaranteed to be around longer than closure
//            // if we don't use weak or unowned, it will be strong by default which will lead to a memory leak
            .addSnapshotListener({ [weak self] (snapshot, error) in
                if let error = error {
                    print("failed to fetch dishes with error: \(error.localizedDescription)")
                } else if let snapshot = snapshot {
                    // anytime there's a modified change to the database our tableview updates
                    self?.blogs = snapshot.documents.map { Blog(dict: $0.data()) }
                        .sorted { $0.createdDate.date() > $1.createdDate.date() }
                }
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Show Dish Details" {
//            guard let indexPath = sender as? IndexPath,
//                let cell = tableView.cellForRow(at: indexPath) as? DishCell,
//                let dishDVC = segue.destination as? DishDetailViewController else {
//                    fatalError("cannot segue to dishDVC")
//            }
//            let dish = dishes[indexPath.row]
//            dishDVC.displayName = cell.displayNameLabel.text
//            dishDVC.dish = dish
//        }
        if segue.identifier == "Show Blog Details" {
            guard let indexPath = sender as? IndexPath,
                let cell = blogFeedTableView.cellForRow(at: indexPath) as? BlogCell,
                let blogDVC = segue.destination as? BlogFeedDetailController else {
                    fatalError("Cannot Segue to BlogDVC")
            }
            let blog = blogs[indexPath.row]
        }
    }

}


extension BlogFeedController: AuthServiceSignOutDelegate {
    func didSignOut(_ authservice: AuthService) {
        listener.remove()
        showLoginView()
    }
    
    func didSignOutWithError(_ authservice: AuthService, error: Error) {
        showAlert(title: "Sign Out Error", message: "Unable to sign out. Please try again.")
    } 
}


extension BlogFeedController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = blogFeedTableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as? BlogCell else {
            fatalError("BlogCell not found")
        }
        let blog = blogs[indexPath.row]
        cell.configureCell(blog: blog)
        return cell
    }
}

extension BlogFeedController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Blog Details", sender: indexPath)
    }
}
