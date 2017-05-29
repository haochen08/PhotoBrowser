//
//  PhotosBrowserViewController.swift
//  PhotoBrowser
//
//  Created by Hao Chen on 2017/5/10.
//  Copyright © 2017年 Hao Chen. All rights reserved.
//

import UIKit


class PhotosBrowserViewController: UICollectionViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    fileprivate let reuseIdentifier = "PhotoCell"
    fileprivate var searches = [FlickrSearchResults]()
    fileprivate let flickr = Flickr()
    fileprivate let cellInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    fileprivate let itemsPerRow = 3
    fileprivate var searchPage = 1
    fileprivate var firstSearchItem = ""
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate var largerIndexPath : IndexPath? {
        didSet {
            var indexPaths = [IndexPath]()
            if let largerIndexPath = largerIndexPath {
                indexPaths.append(largerIndexPath)
            }
            
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }
            
            collectionView?.performBatchUpdates({self.collectionView?.reloadItems(at: indexPaths)}, completion: { (completed) in
                if let largerIndexPath = self.largerIndexPath {
                    self.collectionView?.scrollToItem(at: largerIndexPath, at: .centeredVertically, animated: true)
                }
            })
        }
    }
    
    // No registeration for cell since it is included in the xib
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoBrowserCell
    
        // Configure the cell
        let photo = photoForIndexPath(indexPath: indexPath as NSIndexPath)
        cell.activityIndicator.stopAnimating()
        cell.backgroundColor = UIColor.white
        guard indexPath == largerIndexPath else {
            cell.imageView.image = photo.thumbnail
            return cell
        }
        
        guard photo.largeImage == nil else {
            cell.imageView.image = photo.largeImage
            return cell
        }
        
        cell.imageView.image = photo.thumbnail
        
        cell.activityIndicator.startAnimating()
        photo.loadLargeImage { (photo, error) in
            cell.activityIndicator.stopAnimating()
            
            guard photo.largeImage != nil && error == nil else {
                return
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? PhotoBrowserCell,
                indexPath == self.largerIndexPath {
                cell.imageView.image = photo.largeImage
            }
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "PhotoBrowserHeaderView", for: indexPath) as! PhotoBrowserHeaderView
            headerView.label.text = searches[indexPath.section].searchTerm
            return headerView
        default:
            assert(false, "unexpected element kind")
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        largerIndexPath = largerIndexPath == indexPath ? nil: indexPath
        return false
    }
 

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if spinner.isAnimating {
            return
        }

        let endY = scrollView.contentSize.height - self.view.frame.height + 10.0
        if endY > 0 && scrollView.contentOffset.y >= endY {
            searchTextField.addSubview(spinner)
            spinner.frame = searchTextField.bounds
            spinner.startAnimating()
            
            flickr.searchFlickrForTerm(firstSearchItem, searchPage: searchPage) { (results, error) in
                self.spinner.removeFromSuperview()
                self.spinner.stopAnimating()
                
                if let error = error {
                    print("error in searching: \(error)")
                    return
                }
                
                if let results = results {
                    guard let index = self.searches.index(where: {$0.searchTerm == self.firstSearchItem})else {
                        return
                    }
                    
                    self.searches[index].searchResults += results.searchResults
                    
                    self.collectionView?.reloadData()
                    
                    self.searchPage += 1
                }
            }
        }
    }

}

private extension PhotosBrowserViewController {
    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
}

extension PhotosBrowserViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstSearchItem.isEmpty {
            firstSearchItem = textField.text!
        }
        
        textField.addSubview(spinner)
        spinner.frame = textField.bounds
        spinner.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!, searchPage: searchPage) { (results, error) in
            self.spinner.removeFromSuperview()
            self.spinner.stopAnimating()
            
            if let error = error {
                print("error in searching: \(error)")
                return
            }
            
            if let results = results {
                self.searches.insert(results, at: 0)
                
                self.collectionView?.reloadData()
                
                self.searchPage += 1
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

// New in UICollectionView
extension PhotosBrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = cellInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        
        guard indexPath == largerIndexPath else {
            let widthPerItem = availableWidth / CGFloat(itemsPerRow)
            
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
        
        let flickrPhoto = photoForIndexPath(indexPath: indexPath as NSIndexPath)
        var size = collectionView.bounds.size
        size.height -= topLayoutGuide.length
        size.height -= (cellInsets.top + cellInsets.bottom)
        size.width -= (cellInsets.left + cellInsets.right)
        return flickrPhoto.sizeToFillWidthOfSize(size)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return cellInsets
    }
    
    // Vertical spacing between items in section
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellInsets.top
    }
    
    // Horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellInsets.left
    }
}
