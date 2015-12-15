//
//  SettingsTableViewController.swift
//  mhelse
//
//  Created by Carlo Diaz on 09.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var apiAddress: UITextField!
    @IBOutlet weak var patientId: UITextField!
    @IBOutlet weak var authenticateSwitch: UISwitch!
    @IBOutlet weak var authServerAddress: UITextField!
    @IBOutlet weak var scope: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiAddress.text = Settings.sharedInstance.apiUrl
        patientId.text = Settings.sharedInstance.patientId
        authenticateSwitch.setOn(Settings.sharedInstance.authenticate, animated: false)
        authServerAddress.text = Settings.sharedInstance.authServerUrl
        scope.text = Settings.sharedInstance.authScope
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            Settings.sharedInstance.apiUrl = apiAddress.text!
            Settings.sharedInstance.patientId = patientId.text!
            Settings.sharedInstance.authenticate = authenticateSwitch.on
            Settings.sharedInstance.authServerUrl = authServerAddress.text!
            Settings.sharedInstance.authScope = scope.text!
        }
    }

}
