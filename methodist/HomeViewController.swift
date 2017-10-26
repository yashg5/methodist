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
    
    var binder_id = "BEFeq3aj0WqDXXjh3DiXrs0"
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
        
        callAccessTokenApi(uniqueId: self.cusUniqueID, orgId: nil, firstName: "Yaswanth", lastName: "Gosula", success: { (access_token) in
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
                        vc.binder_id = self.binder_id
                        self.navigationController?.pushViewController(vc, animated: true)
                    }, failure: { (errorMessage) in
                        self.spinner.stopAnimating()
                        DispatchQueue.main.async {
                            self.simpleAlert(message: errorMessage)
                        }
                    })
                }
            })
        }) { (errorMessage) in
            self.spinner.stopAnimating()
            DispatchQueue.main.async {
                self.simpleAlert(message: errorMessage)
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


