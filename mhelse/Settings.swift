//
//  Settings.swift
//  mhelse
//
//  Created by Carlo Diaz on 09.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//

import Foundation

class Settings {
    
    static let sharedInstance = Settings()
    
    fileprivate init()
    {
        apiUrl = ""
        patientId = ""
        authenticate = false
        authServerUrl = ""
        authScope = ""
        
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist")
        {
            if let config = NSDictionary(contentsOfFile: path)
            {
                apiUrl = config.object(forKey: "fhir-api") as! String
                patientId = config.object(forKey: "default-patient") as! String
                authServerUrl = config.object(forKey: "auth-server-url") as! String
                authScope = config.object(forKey: "auth-scope") as! String
            }
        }
    }
    
    var apiUrl: String
    var patientId: String
    var token: String!
    var authenticate: Bool
    var authServerUrl: String
    var authScope: String
}
