//
//  VideoLabel.swift
//  youtube-app
//
//  Created by Michi on 1/28/16.
//  Copyright © 2016 University of Vienna. All rights reserved.
//

import UIKit

class VideoLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsetsMake(0, 5, 0, 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }

}
