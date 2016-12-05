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
    var height, weight, pulse, oxygenSaturation: HKQuantitySample?
    var uploadingCount = 0;
    
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var oxygenSatLabel: UILabel!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        loginButton.isHidden = !Settings.sharedInstance.authenticate
    }
    
    @IBAction func uploadTouched(_ sender: AnyObject)
    {
        uploadingCount = 3
        uploadWeigth()
        uploadPulse()
        uploadOxygenSaturation()
    }
    
    @IBAction func loginTouched(_ sender: AnyObject)
    {
        let provider = OAuthConfig()
        let authenticationViewController = AuthenticationViewController(provider: provider)
        
        authenticationViewController.failureHandler = { error in
            authenticationViewController.dismiss(animated: true, completion: nil)
        }
        
        authenticationViewController.authenticationHandler = { token in
            print("Authenticated: \(token)")
            authenticationViewController.dismiss(animated: true, completion: nil)
            self.loginButton.isEnabled = false;
            self.loginButton.setTitle("Logged in", for: UIControlState.disabled)
            Settings.sharedInstance.token = token
        }
        
        present(authenticationViewController, animated: true, completion: nil)
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
        uploadingCount -= 1
        
        if(uploadingCount == 0)
        {
            DispatchQueue.main.async(execute: { () -> Void in
                let alertController = UIAlertController(title: "Success", message: "Finished uploading to Health Archive!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            });
        }
    }
    
    func showHealthData()
    {
        updateWeight()
        updateHeight()
        updatePulse()
        updateOxygenSaturation()
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
                DispatchQueue.main.async(execute: { () -> Void in
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
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
                DispatchQueue.main.async(execute: { () -> Void in
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                });
            }
        });
    }
    
    func uploadOxygenSaturation()
    {
        healthArchiveManager.uploadOxygenSaturation(oxygenSaturation!, completion: { (data, response, error) -> Void in
            if (error == nil)
            {
                self.printResponse(data!)
                self.finishUpload()
            }
            else
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                });
            }
        });
    }
    
    func updateOxygenSaturation()
    {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentOxyGenSaturation, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading oxygen saturation from HealthKit Store: \(error?.localizedDescription)")
                return;
            }
            
            var localizedString = "unknown";
            self.oxygenSaturation = mostRecentOxyGenSaturation as? HKQuantitySample;
            let unit = HKUnit(from: "%")
            if let percent = self.oxygenSaturation?.quantity.doubleValue(for: unit)
            {
                localizedString = "\(String(format: "%.0f%", percent * 100)) %"
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.oxygenSatLabel.text = localizedString
            });
        });
    }

    func updateWeight()
    {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading weight from HealthKit Store: \(error?.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = "unknown";
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            {
                let weightFormatter = MassFormatter()
                weightFormatter.isForPersonMassUse = true;
                weightLocalizedString = weightFormatter.string(fromKilograms: kilograms)
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.weightLabel.text = weightLocalizedString
            });
        });
    }
    
    func updateHeight()
    {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading height from HealthKit Store: \(error?.localizedDescription)")
                return;
            }
            
            var heightLocalizedString = "unknown";
            self.height = mostRecentHeight as? HKQuantitySample;
            if let meters = self.height?.quantity.doubleValue(for: HKUnit.meter())
            {
                let heightFormatter = LengthFormatter()
                heightFormatter.isForPersonHeightUse = true;
                heightLocalizedString = heightFormatter.string(fromMeters: meters);
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.heightLabel.text = heightLocalizedString
            });
        })
    }
    
    func updatePulse()
    {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentPulse, error) -> Void in
            
            if(error != nil)
            {
                print("Error reading pulse from HealthKit Store: \(error?.localizedDescription)")
                return;
            }
            
            var pulseLocalizedString = "unknown";
            self.pulse = mostRecentPulse as? HKQuantitySample;
            let heartRateUnit = HKUnit(from: "count/min")
            if let beats = self.pulse?.quantity.doubleValue(for: heartRateUnit)
            {
                pulseLocalizedString = "\(String(format:"%.0f", beats)) bpm"
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.pulseLabel.text = pulseLocalizedString
            });
        });
    }
    
    func printResponse(_ data: Data)
    {
        do
        {
            let dataDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            print(dataDictionary)
        }
        catch
        {
            print("Error: cannot read response")
        }
    }
}

