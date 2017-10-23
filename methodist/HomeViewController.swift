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
    var binder_id = "Bsp6ybrHjxw8ec6fym9nsO9"
    var cusUniqueID: String!
    var chatSessions:Array<MXChat>? = nil
    var chatListModel: MXChatListModel?
    
    @IBOutlet weak var welcomeMsg: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.welcomeMsg.text = message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onChatWithNurse(_ sender: UIButton) {
        self.spinner.startAnimating()
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
                if let json = response.result.value as? [String : AnyObject] {
                    if let access_token = json["access_token"] as? String {
                        print("*******access token*****")
                        print(access_token)
                        MXChatClient.sharedInstance().link(withAccessToken: access_token, baseDomain: "sandbox.moxtra.com", completionHandler: { (error) in
                            if error != nil {
                                DispatchQueue.main.async {
                                    self.simpleAlert(message: error!.localizedDescription)
                                }
                            } else {
                                let chatModel = MXChatListModel.init()
                                chatModel.delegate = self
                                self.chatSessions = chatModel.chats()
                                self.getChatViewController(binderID: self.binder_id, success: { (chat, chatViewController) in
                                    self.spinner.stopAnimating()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "chatVC") as! CustomChatViewController
                                    vc.chatView = chatViewController
                                    vc.chat = chat
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }, failure: { (errorMessage) in
                                    self.spinner.stopAnimating()
                                    DispatchQueue.main.async {
                                        self.simpleAlert(message: errorMessage)
                                    }
                                })
                            }
                        })
                    }
                }
            case .failure(let error):
                self.spinner.stopAnimating()
                DispatchQueue.main.async {
                    self.simpleAlert(message: error.localizedDescription)
                }
            }
        }
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
    
    func getChatViewController(binderID:String, scrollToFeed:Any?=nil, success:@escaping (MXChat ,UIViewController)->Void, failure:@escaping (String)->Void)->Void{
        if self.chatSessions != nil {
            let chatItem:MXChat? = self.chatSessions!.filter{$0.chatId==binderID}.first
            if let chat = chatItem {
                if chat.unreadFeedsCount != 0 {
                    UIApplication.shared.applicationIconBadgeNumber = Int(chat.unreadFeedsCount)
                }
                let chatViewController = MXChatViewController.init(chat: chat)
                if let scroll = scrollToFeed{
                    chatViewController.scroll(toFeed: scroll)
                }
                success(chat ,chatViewController)
            } else {
                failure("chat not found in chatSessions array")
            }
        } else {
            failure("No chats found: chatSessions array null")
        }
    }

    // Simple alerts with message and ok action
    func simpleAlert(message: String) {
        let alert = UIAlertController(title: "ONCO-CHAT", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}


