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
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PhotoTableViewCell
        cell.thumbnail.image = searches[indexPath.section].searchResults[indexPath.row].thumbnail
        return cell
    }
}


extension PhotosTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        textField.addSubview(spinner)
        spinner.frame = textField.bounds
        spinner.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!, searchPage: 0) { (results, error) in
            spinner.removeFromSuperview()
            spinner.stopAnimating()
            
            if let error = error {
                print("error in searching: \(error)")
                return
            }
            
            if let results = results {
                self.searches.insert(results, at: 0)
                
                self.tableView?.reloadData()
                
                //self.searchPage += 1
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
