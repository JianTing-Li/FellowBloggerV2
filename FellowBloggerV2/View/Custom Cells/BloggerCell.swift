//
//  BloggerCell.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/22/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class BloggerCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    public func configureCell(blogger: Blogger) {
        if let profileImageURL = blogger.photoURL {
            profileImageView.kf.indicatorType = .activity
            profileImageView.kf.setImage(with: URL(string: profileImageURL), placeholder: #imageLiteral(resourceName: "placeholder.png"))
        }
        userFullNameLabel.text = blogger.fullName
        usernameLabel.text = blogger.displayName
    }
}
