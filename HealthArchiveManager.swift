//
//  HealthArchiveManager.swift
//  mhelse
//
//  Created by Carlo Diaz on 09.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//

import Foundation
import HealthKit

class HealthArchiveManager
{
    func buildWeightData(weight: HKQuantitySample, patientId: String) -> NSDictionary
    {
        let subjectData: NSDictionary = ["reference": "Patient/\(patientId)"]
        
        let codingData: NSDictionary = [
            "system": "urn:std:iso:11073:10101",
            "code": "188736",
            "display": "MDC_MASS_BODY_ACTUAL"]
        
        let codeData: NSDictionary = ["coding": codingData]
        let value = weight.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
        let valueData: NSDictionary = [
            "value": value,
            "unit": "kg",
            "system": "urn:std:iso:11073:10101",
            "code": "263875"]
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return [
            "resourceType": "Observation",
            "code": codeData,
            "subject": subjectData,
            "effectiveDateTime": formatter.stringFromDate(weight.endDate),
            "valueQuantity": valueData]
    }
    
    func buildPulseData(pulse: HKQuantitySample, patientId: String) -> NSDictionary
    {
        let subjectData: NSDictionary = ["reference": "Patient/\(patientId)"]
        
        let codingData: NSDictionary = [
            "system": "https://rtmms.nist.gov",
            "code": "149530",
            "display": "MDC_PULS_OXIM_PULS_RATE"]
        
        let codeData: NSDictionary = ["coding": codingData]
        let heartRateUnit = HKUnit(fromString: "count/min")
        let beats = pulse.quantity.doubleValueForUnit(heartRateUnit)
    
        let valueData: NSDictionary = [
            "value": beats,
            "system": "https://rtmms.nist.gov",
            "code": "264864"]
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return [
            "resourceType": "Observation",
            "code": codeData,
            "subject": subjectData,
            "effectiveDateTime": formatter.stringFromDate(pulse.endDate),
            "valueQuantity": valueData]
    }
    
    func uploadWeigth(weight: HKQuantitySample, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)!)
    {
        let baseURL = NSURL(string: Settings.sharedInstance.apiUrl)
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "Observation", relativeToURL: baseURL)
        request.HTTPMethod = "POST"
        request.setValue("application/json+fhir", forHTTPHeaderField: "Content-Type")
        let data: NSDictionary = buildWeightData(weight, patientId: Settings.sharedInstance.patientId)
        addAuthenticationHeader(request)

        do
        {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
        }
        catch
        {
            print("Error: cannot create JSON data")
        }
        
        let sharedSession = NSURLSession.sharedSession()
        let uploadTask = sharedSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if(completion != nil)
            {
                completion(data, response, error)
            }
        })
        
        uploadTask.resume()
    }
    
    func uploadPulse(pulse: HKQuantitySample, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)!)
    {
        let baseURL = NSURL(string: Settings.sharedInstance.apiUrl)
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: "Observation", relativeToURL: baseURL)
        request.HTTPMethod = "POST"
        request.setValue("application/json+fhir", forHTTPHeaderField: "Content-Type")
        let data: NSDictionary = buildPulseData(pulse, patientId: Settings.sharedInstance.patientId)
        addAuthenticationHeader(request)
        
        do
        {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
        }
        catch
        {
            print("Error: cannot create JSON data")
        }
        
        let sharedSession = NSURLSession.sharedSession()
        let uploadTask = sharedSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if(completion != nil)
            {
                completion(data, response, error)
            }
        })
        
        uploadTask.resume()
    }
    
    func addAuthenticationHeader(request: NSMutableURLRequest)
    {
        if(Settings.sharedInstance.authenticate)
        {
            let value = "Bearer \(Settings.sharedInstance.token)"
            request.setValue(value, forHTTPHeaderField: "Authorization")
        }
    }

}