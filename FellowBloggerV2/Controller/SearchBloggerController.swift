//
//  SearchBloggerController.swift
//  FellowBloggerV2
//
//  Created by Jian Ting Li on 3/14/19.
//  Copyright © 2019 Jian Ting Li. All rights reserved.
//

import UIKit

class SearchBloggerController: UIViewController {

    @IBOutlet weak var bloggerSearchBar: UISearchBar!
    @IBOutlet weak var searchBloggerTableView: UITableView!
    
    private var bloggers = [Blogger]() {
        didSet {
            DispatchQueue.main.async {
                self.searchBloggerTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchAllBloggers()
        bloggerSearchBar.delegate = self
    }
    
    private func configureTableView() {
        searchBloggerTableView.delegate = self
        searchBloggerTableView.dataSource = self
        searchBloggerTableView.register(UINib(nibName: "BloggerCell", bundle: nil), forCellReuseIdentifier: "BloggerCell")
    }
    
    // fetchAllBloggers func only used for testing, it's not part of the app
    private func fetchAllBloggers() {
        DBService.firestoreDB
            .collection(BloggersCollectionKeys.CollectionKey)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("failed to fetch Bloggers with errors: \(error.localizedDescription)")
                } else if let snapshot = snapshot {
                    self?.bloggers = snapshot.documents.map { Blogger(dict: $0.data()) }
                        .sorted { $0.displayName > $1.displayName }
                }
        }
    }
    ////////////////////
    
    private func fetchSearchBloggers(keyword: String, completionHandler: @escaping (Error?, [Blogger]?) -> Void) {
        DBService.firestoreDB
            .collection(BloggersCollectionKeys.CollectionKey)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    completionHandler(error, nil)
                } else if let snapshot = snapshot {
                    let allBloggers = snapshot.documents.map { Blogger(dict: $0.data()) }
                    let filteredByFullname = allBloggers.filter { $0.fullName.lowercased().contains(keyword) }
                        .sorted { $0.fullName > $1.fullName }
                    if !filteredByFullname.isEmpty {
                        completionHandler(nil, filteredByFullname)
                    } else {
                        let filteredByUsername = allBloggers.filter { $0.displayName.lowercased().contains(keyword) }
                            .sorted { $0.displayName > $1.displayName }
                        completionHandler(nil, filteredByUsername)
                    }
                }
        }
    }

}

extension SearchBloggerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bloggers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchBloggerTableView.dequeueReusableCell(withIdentifier: "BloggerCell", for: indexPath) as? BloggerCell else { fatalError("BloggerCell not found") }
        let blogger = bloggers[indexPath.row]
        cell.configureCell(blogger: blogger)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destinationVC = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "ProfileVC") as? ProfileController else {
                print("Can't find ProfileVC")
                return
        }
        let selectedBlogger = bloggers[indexPath.row]
        destinationVC.otherBlogger = selectedBlogger
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension SearchBloggerController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text?.lowercased() else { return }
        fetchSearchBloggers(keyword: searchText) { (error, bloggers) in
            if let error = error {
                self.showAlert(title: "Search Error", message: error.localizedDescription)
                return
            }
            if let bloggers = bloggers {
                if bloggers.isEmpty {
                    self.showAlert(title: "No Blogger Found", message: nil)
                } else {
                    self.bloggers = bloggers
                }
            }
        }
    }
}
