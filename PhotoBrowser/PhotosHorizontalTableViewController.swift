//
//  PhotosHorizontalTableViewController.swift
//  PhotoBrowser
//
//  Created by Hao Chen on 2017/6/17.
//  Copyright © 2017年 Hao Chen. All rights reserved.
//

import UIKit

class PhotosHorizontalTableViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    fileprivate var searches = [FlickrSearchResults]()
    fileprivate let flickr = Flickr()
    fileprivate var searchPage = 1
    fileprivate var searchItem: String!
    
    
    let tableViewCellReusableID = "PhotoHorizontalTableViewCell"
    let collectionViewCellReusableID = "PhotoHorizontalCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellReusableID) as! PhotoHorizontalTableViewCell
        cell.collectionView.indexPathInTableView = indexPath
        cell.collectionView.reloadData()
        return cell
    }

}

extension PhotosHorizontalTableViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellReusableID, for: indexPath) as! PhotoHorizontalCollectionViewCell
        let indexPathInTableView = (collectionView as! PhotoHorizontalCollectionView).indexPathInTableView
        cell.thumbnail.image = searches[(indexPathInTableView?.section)!].searchResults[indexPath.row].thumbnail
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let indexPathInTableView = (collectionView as! PhotoHorizontalCollectionView).indexPathInTableView
        return searches[(indexPathInTableView?.section)!].searchResults.count
    }
}

extension PhotosHorizontalTableViewController : UITextFieldDelegate {
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
                self.searches.append(results)
                self.tableView?.reloadData()
                
                //let indexSet : IndexSet = [self.searchPage-1]
                //self.tableView?.reloadSections(indexSet, with:.automatic)
                
                self.searchPage += 1
            }
        }
        
        searchItem = textField.text
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
