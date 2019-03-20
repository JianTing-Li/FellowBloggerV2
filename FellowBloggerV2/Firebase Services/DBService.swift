//
//  DBService.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/13/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

struct BloggersCollectionKeys {
    static let CollectionKey = "bloggers"
    static let BloggerIdKey = "bloggerId"
    static let DisplayNameKey = "displayName"
    static let FirstNameKey = "firstName"
    static let LastNameKey = "lastName"
    static let EmailKey = "email"
    static let PhotoURLKey = "photoURL"
    static let CoverImageURLKey = "coverImageURL"
    static let JoinedDateKey = "joinedDate"
    static let BioKey = "bio"
}

struct BlogsCollectionKeys {
    static let CollectionKey = "blogs"
    static let BlogDescriptionKey = "blogDescription"
    static let BloggerIdKey = "bloggerId"
    static let CreatedDateKey = "createdDate"
    static let DocumentIdKey = "documentId"
    static let ImageURLKey = "imageURL"
}

final class DBService {
    private init() {}
    
    public static var firestoreDB: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }()
    
    static public var generateDocumentId: String {
        return firestoreDB.collection(BloggersCollectionKeys.CollectionKey).document().documentID
    }
    
    static public func createBlogger(blogger: Blogger, completion: @escaping (Error?) -> Void) {
        firestoreDB.collection(BloggersCollectionKeys.CollectionKey)
            .document(blogger.bloggerId)
            .setData([ BlogsCollectionKeys.BloggerIdKey : blogger.bloggerId,
                       BloggersCollectionKeys.DisplayNameKey : blogger.displayName,
                       BloggersCollectionKeys.EmailKey       : blogger.email,
                       BloggersCollectionKeys.PhotoURLKey    : blogger.photoURL ?? "",
                       BloggersCollectionKeys.JoinedDateKey  : blogger.joinedDate,
                       BloggersCollectionKeys.BioKey         : blogger.bio ?? ""
            ]) { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
        }
    }
    
    // query fuction to get dishes for specific user
    static public func getBlogger(userId: String, completion: @escaping (Error?, Blogger?) -> Void) {
        DBService.firestoreDB
            .collection(BloggersCollectionKeys.CollectionKey)
            .whereField(BloggersCollectionKeys.BloggerIdKey, isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error, nil)
                } else if let snapshot = snapshot?.documents.first {
                    let blogger = Blogger(dict: snapshot.data())
                    completion(nil, blogger)
                }
        }
    }
    
    // writing to firebase:
    // 1. we need a reference to the database - DBService.firestoreDB
    // 2. what collection are you writing to? e.g. "blogs" (BlogsCollectionKeys.CollectionKey)
    // 3. write to the collection e.g. setData, updateData, delete
    // create new document - use setData
    // update exisgting document - use updateData
    static public func postBlog(blog: Blog, completion: @escaping (Error?) -> Void) {
        firestoreDB.collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId).setData([
                BlogsCollectionKeys.CreatedDateKey     : blog.createdDate,
                BlogsCollectionKeys.BloggerIdKey       : blog.bloggerId,
                BlogsCollectionKeys.BlogDescriptionKey  : blog.blogDescription,
                BlogsCollectionKeys.ImageURLKey        : blog.imageURL,
                BlogsCollectionKeys.DocumentIdKey      : blog.documentId
                ])
            { (error) in
                if let error = error {
                    completion(error)
                    print("posting blog error: \(error)")
                } else {
                    completion(nil)
                    print("blog posted successfully to ref: \(blog.documentId)")
                }
        }
    }
    
    static public func deleteDish(blog: Blog, completion: @escaping (Error?) -> Void) {
         // Steps for deleting
                // step 1 --> we need the database reference (DBService.firestoreDB)
                // step 2 --> get the collection we're interested in "(.collection(BlogsCollectionKeys.CollectionKey)"
                // step 3 --> pass in the document id you want to delete (constant time like a  array w/ an index passed in)
        DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .document(blog.documentId)
            .delete { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
        }
    }
}

