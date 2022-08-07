//
//  LaunchScreenViewController.swift
//  Urgent
//
//  Created by jang gukjin on 04/10/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {


    @IBOutlet weak var indicater: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicater.startAnimating()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
