//
//  MainViewController.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Sagar Ayi on 11/1/19.
//  Copyright © 2019 Northeastern. All rights reserved.
//

import WatchKit
import HealthKit

class MainViewController: WKInterfaceController  {
    
    @IBOutlet weak var hearRateLabel: WKInterfaceLabel!
    
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stepsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stepsCounterLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("AWAKE")
        WorkoutTracking.authorizeHealthKit()
        WorkoutTracking.shared.startWorkOut()
        WorkoutTracking.shared.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("WILL ACTIVE")
        WorkoutTracking.shared.fetchStepCounts()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("DID DEACTIVE")
    }
    
}

extension MainViewController: WorkoutTrackingDelegate {
    func didReceiveHealthKitStepCounts(_ stepCounts: Double) {
        if (stepCounts > 0){
            stepsCounterLabel.setText("\(stepCounts) steps")
            print("Started moving")
        }
    }
    
    func didReceiveHealthKitHeartRate(_ heartRate: Double) {
        heartRateCountLabel.setText("\(heartRate) BPM")
    }
}
