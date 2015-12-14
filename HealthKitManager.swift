//
//  HealthManager.swift
//  mhelse
//
//  Created by Carlo Diaz on 07.12.2015.
//  Copyright © 2015 Carlo Diaz. All rights reserved.
//
import Foundation
import HealthKit

class HealthKitManager
{
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        let healthKitTypesToRead = Set( arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!)
        
        healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if(completion != nil)
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func readMostRecentSample(sampleType: HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
    {
        let past = NSDate.distantPast()
        let now = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion(nil,error)
                    return;
                }
                
                let mostRecentSample = results!.first as? HKQuantitySample
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
    }
}