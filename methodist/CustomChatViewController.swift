//
//  CustomChatViewController.swift
//  methodist
//
//  Created by Zemoso Labs on 20/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AWSLex
import AWSAuthCore
import Alamofire

class CustomChatViewController: UIViewController {

    @IBOutlet weak var chatContainerView: UIView!
    
    var chatView:UIViewController?
    var chat:MXChat!
    var binder_id:String!
    let chatConfig = MXChatClient.sharedInstance().chatSessionConfig
    
    var botUniqueID = "bot1"
    
    //Intialized TextBot
    var bot = Bot(name: "OncoBot",
                  description: "Bot to order dress on the behalf of a user",
                  commandsHelp: [
        ],
                  configuration: BotConfiguration(
                    name: OrderFlowersBotName,
                    alias: OrderFlowersBotAlias,
                    region: OrderFlowersBotRegion));
    
    // The interaction kit client
    var interactionKit: AWSLexInteractionKit?
    
    // The session attributes
    var sessionAttributes: [AnyHashable: Any]?
    
    // used to store task completion source of interaction kit
    var textModeSwitchingCompletion: AWSTaskCompletionSource<NSString>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.chatView {
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            vc.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.chatContainerView.frame.size.width, height: self.chatContainerView.frame.size.height))
            self.chatContainerView.addSubview(vc.view)
        }
        
        // setup service configuration for bots
        let configuration = AWSServiceConfiguration(region: self.bot.configuration.region, credentialsProvider: AWSIdentityManager.default().credentialsProvider)
        // setup interaction kit configuration
        let botConfig = AWSLexInteractionKitConfig.defaultInteractionKitConfig(withBotName: self.bot.configuration.name, botAlias: self.bot.configuration.alias)
        // disable automatic voice playback for text demo
        botConfig.autoPlayback = false
        // register the interaction kit client
        AWSLexInteractionKit.register(with: configuration!, interactionKitConfiguration: botConfig, forKey: self.bot.configuration.name)
        // fetch and set the interaction kit client
        self.interactionKit = AWSLexInteractionKit.init(forKey: self.bot.configuration.name)
        // set the interaction kit delegate
        self.interactionKit?.interactionDelegate = self
        
        // intial message from Bot
        
        callAccessTokenApi(uniqueId: self.botUniqueID, orgId: nil, firstName: "Nurse", lastName: nil, success: { (access_token) in
            DispatchQueue.main.async {
                self.sendMessageAsBot(access_token: access_token, message: "Good evening. Mrs. Garcia. How are you?")
            }
        }, failure: { (errorMessage) in
            DispatchQueue.main.async {
                self.simpleAlert(message: errorMessage)
            }
        })
 
        
        // chat configurations
        chatConfig.chatMessageModifyHandler = {(chatItem, viewController, originalMessage) -> String in
            if let textModeSwitchingCompletion = self.textModeSwitchingCompletion {
                textModeSwitchingCompletion.set(result: originalMessage as NSString)
                self.textModeSwitchingCompletion = nil
            }
            else {
                self.interactionKit?.text(inTextOut: originalMessage)
            }
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
    
    func sendMessageAsBot(access_token: String, message: String) {
        // send reply to binder as bot
        
        let msgHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(access_token)",
            "Content-Type": "application/json"
        ]
        
        let msgParameters: Parameters = [
            "text": message
        ]
        
        Alamofire.request("https://apisandbox.moxtra.com/v1/\(self.binder_id!)/comments", method: .post, parameters: msgParameters, encoding: JSONEncoding.default, headers: msgHeaders).validate().responseJSON { response in
            switch response.result {
            case .success:
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.simpleAlert(message: error.localizedDescription)
                }
            }
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

// MARK: Bot Interaction Kit
extension CustomChatViewController: AWSLexInteractionDelegate {
    
    func interactionKit(_ interactionKit: AWSLexInteractionKit, onError error: Error) {
        print("Error occurred: \(error)")
    }
    
    func interactionKit(_ interactionKit: AWSLexInteractionKit, switchModeInput: AWSLexSwitchModeInput, completionSource: AWSTaskCompletionSource<AWSLexSwitchModeResponse>?) {
        self.sessionAttributes = switchModeInput.sessionAttributes
        DispatchQueue.main.async(execute: {
            // Handle a successful fulfillment
            if (switchModeInput.dialogState == AWSLexDialogState.readyForFulfillment) {
            } else {
                callAccessTokenApi(uniqueId: self.botUniqueID, orgId: nil, firstName: "Nurse", lastName: nil, success: { (access_token) in
                    DispatchQueue.main.async {
                        self.sendMessageAsBot(access_token: access_token, message: switchModeInput.outputText!)
                    }
                }, failure: { (errorMessage) in
                    DispatchQueue.main.async {
                        self.simpleAlert(message: errorMessage)
                    }
                })
            }
        })
        
        //this can expand to take input from user.
        let switchModeResponse = AWSLexSwitchModeResponse()
        switchModeResponse.interactionMode = AWSLexInteractionMode.text
        switchModeResponse.sessionAttributes = switchModeInput.sessionAttributes
        completionSource?.set(result: switchModeResponse)
    }
    
    /*
     * Sent to delegate when the Switch mode requires a user to input a text. You should set the completion source result to the string that you get from the user. This ensures that the session attribute information is carried over from the previous request to the next one.
     */
    func interactionKitContinue(withText interactionKit: AWSLexInteractionKit, completionSource: AWSTaskCompletionSource<NSString>) {
        textModeSwitchingCompletion = completionSource
    }
}

