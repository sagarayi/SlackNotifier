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
    
    var counter:Int = 0
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("AWAKE")
        WorkoutTracking.authorizeHealthKit()
        WorkoutTracking.shared.startWorkOut()
        WorkoutTracking.shared.delegate = self
        
//        WatchKitConnection.shared.delegate = self
//        WatchKitConnection.shared.startSession()
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
    
    
    //    extension MainController {
    //        @IBAction func startWorkout() {
    //            WorkoutTracking.shared.startWorkOut()
    //        }
    //
    //        @IBAction func stopWorkout() {
    //            WorkoutTracking.shared.stopWorkOut()
    //        }
    //    }
    
}

extension MainViewController: WorkoutTrackingDelegate {
    func didReceiveHealthKitStepCounts(_ stepCounts: Double) {
        if (stepCounts > 0){
            stepsCounterLabel.setText("\(stepCounts) steps")
            print("Started moving")
        }
    }
    
    func didReceiveHealthKitHeartRate(_ heartRate: Double) {
        counter =  counter + 1
        heartRateCountLabel.setText("\(counter) BPM")
        //            WatchKitConnection.shared.sendMessage(message: ["heartRate":
        //                "\(heartRate)" as AnyObject])
    }
    
    //        func didReceiveHealthKitStepCounts(_ stepCounts: Double) {
    //            stepCountsLabel.setText("\(stepCounts) STEPS")
    //        }
}

//extension MainViewController: WatchKitConnectionDelegate {
//    func didReceiveUserName(_ userName: String) {
//        userNameLabel.setText(userName)
//    }
//}
