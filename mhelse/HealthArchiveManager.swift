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
    func buildWeightData(_ weight: HKQuantitySample, patientId: String) -> NSDictionary
    {
        let codingData: NSDictionary = [
            "system": "urn:std:iso:11073:10101",
            "code": "188736",
            "display": "MDC_MASS_BODY_ACTUAL"]
        let codeData: NSDictionary = ["coding": codingData]
        let value = weight.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
        let valueData: NSDictionary = [
            "value": value,
            "unit": "kg",
            "system": "urn:std:iso:11073:10101",
            "code": "263875"]
        
        return buildObservationData(weight, patientId: patientId, codeData: codeData, valueData: valueData)
    }
    
    func buildPulseData(_ pulse: HKQuantitySample, patientId: String) -> NSDictionary
    {
        let codingData: NSDictionary = [
            "system": "https://rtmms.nist.gov",
            "code": "149530",
            "display": "MDC_PULS_OXIM_PULS_RATE"]
        let codeData: NSDictionary = ["coding": codingData]
        let heartRateUnit = HKUnit(from: "count/min")
        let beats = pulse.quantity.doubleValue(for: heartRateUnit)
        let valueData: NSDictionary = [
            "value": beats,
            "system": "https://rtmms.nist.gov",
            "code": "264864"]
        
        return buildObservationData(pulse, patientId: patientId, codeData: codeData, valueData: valueData)
    }
    
    func buildObservationData(_ sample: HKQuantitySample, patientId: String, codeData: NSDictionary, valueData: NSDictionary) -> NSDictionary
    {
        let subjectData: NSDictionary = ["reference": "Patient/\(patientId)"]
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return [
            "resourceType": "Observation",
            "code": codeData,
            "subject": subjectData,
            "effectiveDateTime": formatter.string(from: sample.endDate),
            "valueQuantity": valueData]
    }
    
    func uploadWeigth(_ weight: HKQuantitySample, completion: ((Data?, URLResponse?, NSError?) -> Void)!)
    {
        let data: NSDictionary = buildWeightData(weight, patientId: Settings.sharedInstance.patientId)
        postObservation(data, completion: completion)
    }
    
    func uploadPulse(_ pulse: HKQuantitySample, completion: ((Data?, URLResponse?, NSError?) -> Void)!)
    {
        let data: NSDictionary = buildPulseData(pulse, patientId: Settings.sharedInstance.patientId)
        postObservation(data, completion: completion)
    }
    
    func postObservation(_ data: NSDictionary, completion: @escaping (Data?, URLResponse?, NSError?) -> Void)
    {
        let baseURL = URL(string: Settings.sharedInstance.apiUrl)
        var request = URLRequest(url: URL(string: "Observation", relativeTo: baseURL)!)

        request.httpMethod = "POST"
        request.setValue("application/json+fhir", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if(Settings.sharedInstance.authenticate)
        {
            let value = "Bearer \(Settings.sharedInstance.token)"
            request.setValue(value, forHTTPHeaderField: "Authorization")
        }
        
        do
        {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        }
        catch
        {
            print("Error: cannot create JSON data")
        }

        let uploadTask = URLSession.shared.dataTask(with: request){
            data, response, err in
            completion(data, response, err as NSError?)
        }
        
        uploadTask.resume()
    }
    
}
