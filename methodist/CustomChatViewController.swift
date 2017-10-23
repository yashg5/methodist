//
//  CustomChatViewController.swift
//  methodist
//
//  Created by Zemoso Labs on 20/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CustomChatViewController: UIViewController {

    @IBOutlet weak var chatContainerView: UIView!
    var chatView:UIViewController?
    var chat:MXChat!
    let chatConfig = MXChatClient.sharedInstance().chatSessionConfig
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.chatView {
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            vc.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.chatContainerView.frame.size.width, height: self.chatContainerView.frame.size.height))
            self.chatContainerView.addSubview(vc.view)
        }
        
        // chat configurations
        chatConfig.chatMessageModifyHandler = {(chatItem, viewController, originalMessage) -> String in
            print(originalMessage)
            return originalMessage
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
