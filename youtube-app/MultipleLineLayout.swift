//
//  MultipleLineLayout.swift
//  youtube-app
//
//  Created by Michi on 1/25/16.
//  Copyright © 2016 University of Vienna. All rights reserved.
//

import UIKit

class MultipleLineLayout: UICollectionViewFlowLayout {
    
    //#define space 5
    
    var itemWidth: Int = 60
    var itemHeight: Int = 60
    
    let space = 5
    
    override func collectionViewContentSize() -> CGSize {
        super.collectionViewContentSize()
        let xSize = CGFloat((self.collectionView?.numberOfItemsInSection(0))! * (itemWidth + space))
        let ySize = CGFloat((self.collectionView?.numberOfSections())! * (itemHeight + space))
        return CGSizeMake(xSize, ySize)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.size = CGSizeMake(CGFloat(itemWidth),CGFloat(itemHeight))
        
        let xValue = CGFloat(itemWidth/2 + indexPath.row * (itemWidth + space))
        let yValue = CGFloat(itemHeight + indexPath.section * (itemHeight + space))
        
        attributes.center = CGPointMake(xValue, yValue)
        
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let minRow = rect.origin.x > 0 ? Int(rect.origin.x/CGFloat(itemWidth + space)) : 0 // need to check because bounce gives negative values for x.
        let maxRow = Int(rect.size.width/CGFloat(itemWidth + space) + CGFloat(minRow))
        var attributes = [UICollectionViewLayoutAttributes]()
        
        for section in 0 ..< self.collectionView!.numberOfSections() {
            for row in minRow ..< maxRow {
                let indexPath = NSIndexPath(forItem: row, inSection: section)
                attributes.append(UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath))
            }
        }
        return attributes
    }
    
}
