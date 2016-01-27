//
//  DataCell.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 1/25/16.
//  Copyright © 2016 University of Vienna. All rights reserved.
//

import UIKit

class DataCell: UICollectionViewCell {
    
    var label = UILabel()
    
    override required init(frame: CGRect){
        super.init(frame: frame)
        
        label = UILabel(frame: CGRectMake(10,15,40,30))
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(1).CGColor
        
        self.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.6, alpha: 1)
        self.layer.cornerRadius = 5.0
        self.contentView.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
