//
//  ProfileEditCell.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/20/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class ProfileEditCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    
    public func configureCell(profileComponent: ProfileComponent, profileComponents: [ProfileComponent : String] , tag: Int) {
        contentTextField.tag = tag
        switch profileComponent {
        case .firstName:
            contentLabel.text = "First Name"
            contentTextField.text = profileComponents[.firstName]
        case .lastName:
            contentLabel.text = "Last Name"
            contentTextField.text = profileComponents[.lastName]
        case .userName:
            contentLabel.text = "Username"
            contentTextField.text = profileComponents[.userName]
        case .bio:
            break
        }
    }
}
