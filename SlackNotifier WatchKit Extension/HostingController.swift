//
//  HostingController.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Rajath Kashyap on 10/18/19.
//  Copyright © 2019   . All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import HealthKit

class HostingController: WKHostingController<ContentView> {
    var heartRateQuery:HKObserverQuery?
    let healthStore: HKHealthStore = HKHealthStore()
    override var body: ContentView {
        return ContentView()
    }
}
