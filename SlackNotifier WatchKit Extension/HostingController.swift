//
//  HostingController.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Sagar Ayi on 10/18/19.
//  Copyright © 2019 Northeastern. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import HealthKit

class HostingController: WKHostingController<ContentView> {
    var heartRateQuery:HKObserverQuery?
    let healthStore: HKHealthStore = HKHealthStore()
    override var body: ContentView {
//        subscribeToHeartBeatChanges()
        return ContentView()
    }
//}
    
//  public func subscribeToHeartBeatChanges() {
//
//      // Creating the sample for the heart rate
//      guard let sampleType: HKSampleType =
//        HKObjectType.quantityType(forIdentifier: .heartRate) else {
//          return
//      }
//
//      /// Creating an observer, so updates are received whenever HealthKit’s
//      // heart rate data changes.
//      self.heartRateQuery = HKObserverQuery.init(
//        sampleType: sampleType,
//        predicate: nil) { [weak self] _, _, error in
//          guard error == nil else {
////            log.warn(error!)
//            return
//          }
//
//          /// When the completion is called, an other query is executed
//          /// to fetch the latest heart rate
//            self?.fetchLatestHeartRateSample(completion: { sample in
//            guard let sample = sample else {
//              return
//            }
//
//            /// The completion in called on a background thread, but we
//            /// need to update the UI on the main.
//            DispatchQueue.main.async {
//
//              /// Converting the heart rate to bpm
//              let heartRateUnit = HKUnit(from: "count/min")
//              let heartRate = sample
//                .quantity
//                .doubleValue(for: heartRateUnit)
//
//              /// Updating the UI with the retrieved value
//                print("HeartRate is \(heartRate)" )
//                ContentView()
//            }
//          })
//      }
//    }
//
//    public func fetchLatestHeartRateSample(
//      completion: @escaping (_ sample: HKQuantitySample?) -> Void) {
//
//      /// Create sample type for the heart rate
//      guard let sampleType = HKObjectType
//        .quantityType(forIdentifier: .heartRate) else {
//          completion(nil)
//        return
//      }
//
//      /// Predicate for specifiying start and end dates for the query
//      let predicate = HKQuery
//        .predicateForSamples(
//          withStart: Date.distantPast,
//          end: Date(),
//          options: .strictEndDate)
//
//      /// Set sorting by date.
//      let sortDescriptor = NSSortDescriptor(
//        key: HKSampleSortIdentifierStartDate,
//        ascending: false)
//
//      /// Create the query
//      let query = HKSampleQuery(
//        sampleType: sampleType,
//        predicate: predicate,
//        limit: Int(HKObjectQueryNoLimit),
//        sortDescriptors: [sortDescriptor]) { (_, results, error) in
//
//          guard error == nil else {
//            print("Error: \(error!.localizedDescription)")
//            return
//          }
//
//          completion(results?[0] as? HKQuantitySample)
//      }
//
//      self.healthStore.execute(query)
//    }
}
