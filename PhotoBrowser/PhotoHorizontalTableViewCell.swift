//
//  PhotoHorizontalTableViewCell.swift
//  PhotoBrowser
//
//  Created by Hao Chen on 2017/6/17.
//  Copyright © 2017年 Hao Chen. All rights reserved.
//

import Foundation
import UIKit


class PhotoHorizontalCollectionView: UICollectionView {
    var indexPathInTableView : IndexPath!
}

class PhotoHorizontalTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: PhotoHorizontalCollectionView!
}

class PhotoHorizontalCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
}


