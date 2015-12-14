//
//  TappableVisualEffectView.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/14/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit

class TappableVisualEffectView: UIVisualEffectView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("dont touch me")
        self.removeFromSuperview()
    }
    

    
}
