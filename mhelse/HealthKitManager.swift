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
    
    func authorizeHealthKit(completion: @escaping (Bool, NSError?) -> Void)
    {
        let healthKitTypesToRead = Set( arrayLiteral:
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!)
        
        healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
            completion(success, error as NSError?)
        }
    }
    
    func readMostRecentSample(_ sampleType: HKSampleType , completion: @escaping (HKSample?, NSError?) -> Void)
    {
        let past = Date.distantPast
        let now = Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end:now, options: HKQueryOptions())
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if error != nil {
                    completion(nil,error as NSError?)
                    return;
                }
                
                let mostRecentSample = results!.first as? HKQuantitySample
                completion(mostRecentSample,nil)
                
        }
        
        self.healthKitStore.execute(sampleQuery)
    }
}
