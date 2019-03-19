//
//  ProfileHeaderView.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/15/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate: AnyObject {
    func willSignOut(profileHeaderView: ProfileHeaderView)
    func willEditProfile(profileHeaderView: ProfileHeaderView)
}

class ProfileHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profieImageView: UIImageView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    weak var delegate: ProfileHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        delegate?.willSignOut(profileHeaderView: self)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        delegate?.willEditProfile(profileHeaderView: self)
    }
    
}
