//
//  CustomChatViewController.swift
//  methodist
//
//  Created by Zemoso Labs on 20/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import UIKit

class CustomChatViewController: UIViewController {

    @IBOutlet weak var chatContainerView: UIView!
    var chatView:UIViewController?
    var chat:MXChat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let vc = self.chatView {
            print(vc)
            self.addChildViewController(vc)
            vc.view.frame = CGRect(origin: CGPoint(x:0, y:0), size:CGSize(width:self.chatContainerView.frame.size.width, height:self.chatContainerView.frame.size.height))
            self.chatContainerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
