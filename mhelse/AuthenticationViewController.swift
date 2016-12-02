//
//  AuthenticationViewController.swift
//  mhelse
//
//  Created by Carlo Diaz on 10.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

public enum AuthenticationError: Error {
    case invalidToken
    case userCancelled
}

open class AuthenticationViewController: UINavigationController {
    
    typealias AuthenticationHandler = (String) -> Void
    typealias FailureHandler = (AuthenticationError) -> Void

    var authenticationHandler: AuthenticationHandler?
    var failureHandler: FailureHandler?
    
    fileprivate let provider: OAuthConfig

    public init(provider: OAuthConfig) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported. Did you mean to use init(provider:)?")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticationURL = provider.authorizationURL
        let safariViewController = SFSafariViewController(url: authenticationURL as URL)
        safariViewController.title = provider.title
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AuthenticationViewController.didTapCancel))
        safariViewController.navigationItem.rightBarButtonItem = cancelButton
        setViewControllers([safariViewController], animated: false)
    }
    
    internal func didTapCancel() {
        failureHandler?(.userCancelled)
    }
    
    open func authenticateWithToken (_ token: String)
    {
        self.authenticationHandler?(token)
    }
    
}
