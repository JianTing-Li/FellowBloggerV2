//
//  LikeStatus.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/19/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import Foundation


// Extra Credit (NOT implemented yet)
enum LikeStatus {
    case isLiked
    case noStatus
}

struct LikesCollectionKeys {
    static let CollectionKey = "likes"
    static let LikeIdKey = "likeId"
    static let BlogIdKey = "blogId"
    static let LikedByKey = "likedBy"
    static let CreatedDateKey = "createdDate"
}


class Like {
    let likeId: String
    let blogId: String
    let likedBy: String
    let createdDate: String
    
    init(likeId: String, blogId: String, likedBy: String, createdDate: String) {
        self.likeId = likeId
        self.blogId = blogId
        self.likedBy = likedBy
        self.createdDate = createdDate
    }
    
    init(dict: [String: Any]) {
        self.likeId = dict[LikesCollectionKeys.LikeIdKey] as? String ?? ""
        self.blogId = dict[LikesCollectionKeys.BlogIdKey] as? String ?? ""
        self.likedBy = dict[LikesCollectionKeys.LikedByKey] as? String ?? ""
        self.createdDate = dict[LikesCollectionKeys.CreatedDateKey] as? String ?? ""
    }
}


