//
//  NodeLayout.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 1/25/16.
//  Copyright © 2016 University of Vienna. All rights reserved.
//

import UIKit

class NodeLayout : UICollectionViewFlowLayout {
    var itemWidth : CGFloat
    var itemHeight : CGFloat
    var space : CGFloat
    init(itemWidth: CGFloat, itemHeight: CGFloat, space: CGFloat) {
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.space = space
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        self.itemWidth = 500
        self.itemHeight = 200
        self.space = 0
        super.init()
    }
    override func collectionViewContentSize() -> CGSize {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            return super.collectionViewContentSize()
        }
        
        
        let w : CGFloat = CGFloat(self.collectionView!.numberOfItemsInSection(0)) * (itemWidth + space)
        let h : CGFloat = CGFloat(self.collectionView!.numberOfSections()) * (itemHeight + space)
        return CGSizeMake(w, h)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            return super.layoutAttributesForItemAtIndexPath(indexPath)
        }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let x : CGFloat = CGFloat(indexPath.row) * (itemWidth + space)
        let y : CGFloat = CGFloat(indexPath.section) + CGFloat(indexPath.section) * (itemHeight + space)
        attributes.frame = CGRectMake(x, y, itemWidth, itemHeight)
        return attributes
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            return super.layoutAttributesForElementsInRect(rect)
        }
        
        let minRow : Int = (rect.origin.x > 0) ? Int(rect.origin.x/(itemWidth + space)) : 0
        let maxRow : Int = Int(floor(rect.size.width/(itemWidth + space)) + CGFloat(minRow))
        var attributes : Array<UICollectionViewLayoutAttributes> = [UICollectionViewLayoutAttributes]()
        for i in 0..<5 {
            for j in 0..<5 {

                attributes.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: j, inSection: i))!)
            }
        }
        if self.collectionView!.numberOfItemsInSection(0)>0 {
            return attributes
        } else {
            return nil
        }
        
        
    }

}
