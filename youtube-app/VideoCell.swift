//
//  VideoCell.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/9/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit

class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
        
    var imageView: UIImageView!
    
    // Offset to Create parallax Effect
    var imageOffset:CGPoint!
    
    //Using Closures !!
    
    var image:UIImage!{
        get{
            return self.image
        }
        set{
            self.imageView.image = newValue
            if imageOffset != nil{
                setImageOffset(imageOffset)
            }else{
                setImageOffset(CGPointMake(0, 0))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageView()
    }
    
    func setupImageView(){
        self.clipsToBounds = true
        imageView = UIImageView(frame: frame)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = false
        imageView.layer.zPosition = -1;
        self.addSubview(imageView)
    }
    
    func setImageOffset(imageOffset:CGPoint) {
        self.imageOffset = imageOffset
        let frame:CGRect = imageView.bounds
        let offsetFrame:CGRect = CGRectOffset(frame, self.imageOffset.x, self.imageOffset.y)
        imageView.frame = offsetFrame
    }
    
}
