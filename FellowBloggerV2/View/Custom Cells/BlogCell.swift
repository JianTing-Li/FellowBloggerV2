//
//  BlogCell.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/17/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit
import Firebase

class BlogCell: UITableViewCell {
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var blogTitleLabel: UILabel!
    @IBOutlet weak var blogImageView: CornerImageView!
    
    public func configureCell(blog: Blog) {
        self.selectionStyle = .none
        blogTitleLabel.text = blog.blogDescription
        blogImageView.kf.indicatorType = .activity
        blogImageView.kf.setImage(with: URL(string: blog.imageURL), placeholder: #imageLiteral(resourceName: "placeholder.png"))
        fetchBlogCreator(userID: blog.bloggerId, cell: self, blog: blog)
    }

    private func fetchBlogCreator(userID: String, cell: BlogCell, blog: Blog) {
        DBService.getBlogger(userId: userID) { (error, blogger) in
            if let error = error {
                print("failed to fetch blogger with error: \(error.localizedDescription)")
            } else if let blogger = blogger, let profileImageUrl = blogger.photoURL {
                self.profileImageView.kf.indicatorType = .activity
                self.profileImageView.kf.setImage(with: URL(string: profileImageUrl), placeholder: #imageLiteral(resourceName: "placeholder.png"))
            }
        }
    }
}
