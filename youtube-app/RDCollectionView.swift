//
//  RDCollectionView.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 1/25/16.
//  Copyright © 2016 University of Vienna. All rights reserved.
//

import UIKit

class RDCollectionView: UICollectionView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        let currentOffset = self.contentOffset;
        let contentWidth = self.contentSize.width;
        let contentHeight = self.contentSize.height;
        let centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0
        let centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0
        let distanceFromCenterX = abs(currentOffset.x - centerOffsetX)
        let distanceFromCenterY = abs(currentOffset.y - centerOffsetY)
        
        if distanceFromCenterX > contentWidth/4.0 { // this number of 4.0 is arbitrary
            self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        }
        if distanceFromCenterY > contentHeight/4.0 {
            self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);
        }
    }
    */
    
}
