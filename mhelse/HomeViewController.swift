//
//  ViewController.swift
//  mhelse
//
//  Created by Carlo Diaz on 04.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//

import UIKit
import HealthKit

class HomeViewController: UIViewController
{
    let healthManager:HealthKitManager = HealthKitManager()
    let healthArchiveManager:HealthArchiveManager = HealthArchiveManager()
    var height, weight, pulse: HKQuantitySample?
    var uploadingCount = 0;
    
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        uploadButton.layer.cornerRadius = 20
        authorizeHealthKit()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        loginButton.hidden = !Settings.sharedInstance.authenticate
    }
    
    @IBAction func uploadTouched(sender: AnyObject)
    {
        uploadingCount = 2
        uploadWeigth()
        uploadPulse()
    }
    
    @IBAction func loginTouched(sender: AnyObject)
    {
        let provider = OAuthConfig()
        let authenticationViewController = AuthenticationViewController(provider: provider)
        
        authenticationViewController.failureHandler = { error in
            authenticationViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        authenticationViewController.authenticationHandler = { token in
            print("Authenticated: \(token)")
            authenticationViewController.dismissViewControllerAnimated(true, completion: nil)
            self.loginButton.enabled = false;
            self.loginButton.setTitle("Logged in", forState: UIControlState.Disabled)
            Settings.sharedInstance.token = token
        }
        
        presentViewController(authenticationViewController, animated: true, completion: nil)
    }
    
    func authorizeHealthKit()
    {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized
            {
                self.showHealthData()
            }
            else
            {
                self.showAccessDenied()
                
                if error != nil
                {
                    print("\(error)")
                }
            }
        }
    }
    
    func finishUpload()
    {
        uploadingCount--
        
        if(uploadingCount == 0)
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alertController = UIAlertController(title: "Success", message: "Finished uploading to Health Archive!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            });
        }
    }
    
    func showHealthData()
    {
        updateWeight()
        updateHeight()
        updatePulse()
    }
    
    func showAccessDenied()
    {
        print("HealthKit authorization denied!")
    }
    
    func uploadWeigth()
    {
        healthArchiveManager.uploadWeigth(weight!, completion: { (data, response, error) -> Void in
            if (error == nil)
            {
                self.printResponse(data!)
                self.finishUpload()
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                });
            }
        });
    }
    
    func uploadPulse()
    {
        healthArchiveManager.uploadPulse(pulse!, completion: { (data, response, error) -> Void in
            if (error == nil)
            {
                self.printResponse(data!)
                self.finishUpload()
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                });
            }
        });
    }

    func updateWeight()
    {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = "unknown";
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
            {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.weightLabel.text = weightLocalizedString
            });
        });
    }
    
    func updateHeight()
    {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var heightLocalizedString = "unknown";
            self.height = mostRecentHeight as? HKQuantitySample;
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit())
            {
                let heightFormatter = NSLengthFormatter()
                heightFormatter.forPersonHeightUse = true;
                heightLocalizedString = heightFormatter.stringFromMeters(meters);
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.heightLabel.text = heightLocalizedString
            });
        })
    }
    
    func updatePulse()
    {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentPulse, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading pulse from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var pulseLocalizedString = "unknown";
            self.pulse = mostRecentPulse as? HKQuantitySample;
            let heartRateUnit = HKUnit(fromString: "count/min")
            if let beats = self.pulse?.quantity.doubleValueForUnit(heartRateUnit)
            {
                pulseLocalizedString = "\(String(format:"%.0f", beats)) bpm"
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.pulseLabel.text = pulseLocalizedString
            });
        });
    }
    
    func printResponse(data: NSData)
    {
        do
        {
            let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            print(dataDictionary)
        }
        catch
        {
            print("Error: cannot read response")
        }
    }
}

