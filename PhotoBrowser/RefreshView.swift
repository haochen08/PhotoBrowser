//
//  RefreshView.swift
//  PhotoBrowser
//
//  Created by Hao Chen on 2017/5/29.
//  Copyright © 2017年 Hao Chen. All rights reserved.
//

import UIKit

protocol RefreshViewDelegate {
    func refreshViewDidRefresh()
}

class RefreshView: UIView, UIScrollViewDelegate {
    let kToRefreshText = "Pull to Refreshing"
    let kRefreshingText = "Loading"
    let offsetThreshold = CGFloat(120.0)
    var delegate: RefreshViewDelegate!
    
    var label: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    init(frame: CGRect, delegate:RefreshViewDelegate) {
        super.init(frame:frame)
        
        self.delegate = delegate
        label = UILabel.init()
        label.text = kToRefreshText
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        let constraintX = NSLayoutConstraint.init(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let constraintY = NSLayoutConstraint.init(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addConstraint(constraintX)
        addConstraint(constraintY)
        
        super.updateConstraints()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y <= -offsetThreshold {
            delegate.refreshViewDidRefresh()
            
            label.text = kRefreshingText
            scrollView.contentInset.top += offsetThreshold
            targetContentOffset.pointee = CGPoint.init(x: 0, y: -scrollView.contentInset.top)
        }
    }
    
    open func endRefreshing(_ scrollView: UIScrollView) {
        label.text = kToRefreshText
        scrollView.contentInset.top -= offsetThreshold
    }
    

}
