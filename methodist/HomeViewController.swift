//
//  HomeViewController.swift
//  methodist
//
//  Created by Zemoso Labs on 18/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController, MXChatListModelDelegate {

    var message: String!
    
    // Moxtra Initialize values with sandbox details
    var clientID = "oEgwC6qemCc"
    var clientSecret = "soXXY4cuu0M"
    var cusUniqueID: String!
    
    @IBOutlet weak var welcomeMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.welcomeMsg.text = message
        
        // Autheticate user againt Moxtra to get access_token
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters: Parameters = [
            "client_id": self.clientID,
            "client_secret": self.clientSecret,
            "grant_type": "http://www.moxtra.com/auth_uniqueid",
            "uniqueid": self.cusUniqueID,
            "timestamp": String(Date().timeIntervalSince1970 * 1000),
            "firstname": "yaswanth",
            "lastname": "gosula"
        ]

        Alamofire.request("https://apisandbox.moxtra.com/oauth/token", method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        print("JSON: \(json)")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
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
