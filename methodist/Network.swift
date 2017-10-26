//
//  Network.swift
//  methodist
//
//  Created by Zemoso Labs on 24/10/17.
//  Copyright © 2017 Zemoso Labs. All rights reserved.
//

import Foundation
import Alamofire

// Moxtra Initialize values with sandbox details
var clientID = "oEgwC6qemCc"
var clientSecret = "soXXY4cuu0M"

// Autheticate user againt Moxtra to get access_token
func callAccessTokenApi(uniqueId: String, orgId:String?=nil, firstName:String?=nil, lastName:String?=nil, success:@escaping (String) -> Void, failure:@escaping (String) -> Void) -> Void {
    
    let headers: HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    let parameters: Parameters = [
        "client_id": clientID,
        "client_secret": clientSecret,
        "grant_type": "http://www.moxtra.com/auth_uniqueid",
        "uniqueid": uniqueId,
        "timestamp": String(Date().timeIntervalSince1970 * 1000),
        "firstname": firstName ?? "",
        "lastname": lastName ?? ""
    ]
    
    Alamofire.request("https://apisandbox.moxtra.com/oauth/token", method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
        switch response.result {
        case .success:
            if let json = response.result.value as? [String : AnyObject] {
                if let access_token = json["access_token"] as? String {
                    DispatchQueue.main.async {
                        success(access_token)
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                failure(error.localizedDescription)
            }
        }
    }
}
