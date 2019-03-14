//
//  VC+Extensions.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/14/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showAlert(title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
