//
//  OAuthConfig.swift
//  mhelse
//
//  Created by Carlo Diaz on 11.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//

import Foundation

public struct OAuthConfig {
    
    let title: String?
    let clientId = "mhelse"
    let responseType = "token"
    let clientSecret = ""
    let scope: String
    let redirectURI = "mhelse://authorize"
    let nonce: String
    let state: String
    
    var authorizationURL: NSURL {
        return NSURL(string: "\(Settings.sharedInstance.authServerUrl)?client_id=\(clientId)&scope=\(scope)&redirect_uri=\(redirectURI)&response_type=\(responseType)&nonce=\(nonce)&state=\(state)")!
    }
    
    static func getRandomString() -> String
    {
        return NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
    }

    init()
    {
        self.title = "FHIR"
        self.nonce = OAuthConfig.getRandomString()
        self.state = OAuthConfig.getRandomString()
        self.scope = Settings.sharedInstance.authScope
    }
}