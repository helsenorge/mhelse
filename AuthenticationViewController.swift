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

public enum AuthenticationError: ErrorType {
    case InvalidToken
    case UserCancelled
}

public class AuthenticationViewController: UINavigationController {
    
    typealias AuthenticationHandler = (String) -> Void
    typealias FailureHandler = (AuthenticationError) -> Void

    var authenticationHandler: AuthenticationHandler?
    var failureHandler: FailureHandler?
    
    private let provider: OAuthConfig

    public init(provider: OAuthConfig) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported. Did you mean to use init(provider:)?")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticationURL = provider.authorizationURL
        let safariViewController = SFSafariViewController(URL: authenticationURL)
        safariViewController.title = provider.title
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("didTapCancel"))
        safariViewController.navigationItem.rightBarButtonItem = cancelButton
        setViewControllers([safariViewController], animated: false)
    }
    
    internal func didTapCancel() {
        failureHandler?(.UserCancelled)
    }
    
    public func authenticateWithToken (token: String)
    {
        self.authenticationHandler?(token)
    }
    
}