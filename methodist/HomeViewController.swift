//
//  HomeViewController.swift
//  methodist
//
//  Created by Zemoso Labs on 18/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var message: String!
    
    // Moxtra Initialize values
    var clientID = "oEgwC6qemCc"
    var clientSecret = "soXXY4cuu0M"
    var cusUniqueID: String!
    
    @IBOutlet weak var welcomeMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.welcomeMsg.text = message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onChatWithNurse(_ sender: UIButton) {
    }
    
    @IBAction func onViewMyRecord(_ sender: UIButton) {
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
