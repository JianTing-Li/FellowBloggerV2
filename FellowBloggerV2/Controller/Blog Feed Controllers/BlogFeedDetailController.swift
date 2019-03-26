//
//  BlogFeedDetailController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class BlogFeedDetailController: UIViewController {

    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var blogImageView: UIImageView!
    @IBOutlet weak var blogDescriptionLabel: UILabel!
    
    private var authService = AppDelegate.authservice
    
    var blog: Blog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        setProfileImageAndLabel(userID: blog.bloggerId)
        blogDescriptionLabel.text = blog.blogDescription
        blogImageView.kf.setImage(with: URL(string: blog.imageURL), placeholder: #imageLiteral(resourceName: "placeholder.png"))
    }
    private func setProfileImageAndLabel(userID: String) {
        DBService.getBlogger(userId: userID) { (error, blogger) in
            if let error = error {
                print("failed to fetch blogger with error: \(error.localizedDescription)")
            } else if let blogger = blogger, let profileImageUrl = blogger.photoURL {
                self.profileLabel.text = "@" + blogger.displayName
                self.profileImageView.kf.indicatorType = .activity
                self.profileImageView.kf.setImage(with: URL(string: profileImageUrl), placeholder: #imageLiteral(resourceName: "placeholder.png"))
            }
        }
    }
    
    @IBAction func optionButtonPressed(_ sender: UIButton) {
        guard let user = authService.getCurrentUser() else {
            showAlert(title: "No Logged User", message: nil)
            print("no logged user")
            return
        }
        var actionTitles = [String]()
        actionTitles = user.uid == blog.bloggerId ? ["Save Image", "Edit", "Delete"] : ["Save Image"]
        showActionSheet(title: nil, message: nil, actionTitles: actionTitles, handlers: [{ [weak self] (saveImageAction) in
            if let image = self?.blogImageView.image { UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) }
            }, { [weak self] (editBlogAction) in
               self?.segueToEditBlogVC()
            }, { [weak self] (deleteBlogAction) in
                self?.deleteBlog()
            }
            ])
    }
    
    private func deleteBlog() {
        DBService.deleteDish(blog: blog) { [weak self] (error) in
            if let error = error {
                self?.showAlert(title: "Delete Blog Error", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Blog Deleted", message: nil, handler: { (action) in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    private func segueToEditBlogVC() {
        performSegue(withIdentifier: "Show Edit Blog", sender: nil)
    }
    
    
    // setting up unwind segue
    // Step 1: create unwindFrom...function
    // writing this function in view controller unwinding to
    @IBAction func unwindFromEditBlogFeedView(segue: UIStoryboardSegue) {
        // Unwind segue to reflect the change so the listener knows there's a change
        let editVC = segue.source as! EditBlogController
        blogDescriptionLabel.text = editVC.blogDescriptionTextView.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Edit Blog" {
            guard let navController = segue.destination as? UINavigationController,
                let editVC = navController.viewControllers.first as? EditBlogController else {
                    fatalError("failed to segue to editVC")
            }
            editVC.blog = blog
        }
    }
    

}
