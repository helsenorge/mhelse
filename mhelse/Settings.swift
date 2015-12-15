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
    
    private init()
    {
        apiUrl = ""
        patientId = ""
        authenticate = false
        authServerUrl = ""
        authScope = ""
        
        if let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")
        {
            if let config = NSDictionary(contentsOfFile: path)
            {
                apiUrl = config.objectForKey("fhir-api") as! String
                patientId = config.objectForKey("default-patient") as! String
                authServerUrl = config.objectForKey("auth-server-url") as! String
                authScope = config.objectForKey("auth-scope") as! String
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