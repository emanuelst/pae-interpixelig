//
//  TappableSubviewNavBar.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/13/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit

class TappableSubviewNavBar: UINavigationBar {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    //override hitTest like http://stackoverflow.com/questions/11770743/capturing-touches-on-a-subview-outside-the-frame-of-its-superview-using-hittest
    //to register tabs outside this superviews bounds
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if(!self.clipsToBounds && !self.hidden && self.alpha > 0.0) {
            let subviews = self.subviews.reverse()
            for member in subviews {
                let subPoint = member.convertPoint(point, fromView: self)
                if let result:UIView = member.hitTest(subPoint, withEvent:event) {
                    return result;
                }
            }
        }
        // this fixes our back button not working
        return super.hitTest(point, withEvent: event)
    }
    
}


