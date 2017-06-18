//
//  PhotosTableViewController.swift
//  PhotoBrowser
//
//  Created by Hao Chen on 2017/5/28.
//  Copyright © 2017年 Hao Chen. All rights reserved.
//

import Foundation
import UIKit


class PhotosTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate let reuseIdentifier = "PhotoTableViewCell"
    fileprivate var searches = [FlickrSearchResults]()
    fileprivate let flickr = Flickr()
    fileprivate var searchPage = 1
    fileprivate var searchItem: String!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var refreshView: RefreshView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        // Key code
        // It seems the value here does not matter
        tableView.estimatedRowHeight = 30
        
        let frame = CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 150.0)
        refreshView = RefreshView.init(frame: frame, delegate: self)
        view.insertSubview(refreshView, at: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PhotoTableViewCell
        cell.thumbnail.image = searches[indexPath.section].searchResults[indexPath.row].thumbnail
        let rand_index = arc4random_uniform(4)
        cell.comment.text = labelText[Int(rand_index)]
        return cell
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension PhotosTableViewController : RefreshViewDelegate {
    func refreshViewDidRefresh() {
        flickr.searchFlickrForTerm(searchItem, searchPage: searchPage) { (results, error) in
            self.refreshView.endRefreshing(self.view as! UIScrollView)
            
            if let error = error {
                print("error in searching: \(error)")
                return
            }
            
            if let results = results {
                guard let index = self.searches.index(where: {$0.searchTerm == self.searchItem})else {
                    return
                }
                
                self.searches[index].searchResults.insert(contentsOf: results.searchResults, at: 0)
                
                self.tableView?.reloadData()
                
                self.searchPage += 1
            }
        }
    }
}

extension PhotosTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        textField.addSubview(spinner)
        spinner.frame = textField.bounds
        spinner.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!, searchPage: searchPage) { (results, error) in
            spinner.removeFromSuperview()
            spinner.stopAnimating()
            
            if let error = error {
                print("error in searching: \(error)")
                return
            }
            
            if let results = results {
                self.searches.insert(results, at: 0)
                
                self.tableView?.reloadData()
                
                self.searchPage += 1
            }
        }
        
        searchItem = textField.text
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
