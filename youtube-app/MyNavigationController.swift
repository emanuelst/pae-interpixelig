//
//  MyNavigationController.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 1/29/16.
//  Copyright © 2016 University of Vienna. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // hack, as described here:
    // http://stackoverflow.com/a/29065069/841052
    // http://openradar.appspot.com/radar?id=5788623576236032
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
