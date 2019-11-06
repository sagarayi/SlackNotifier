//
//  MainViewController.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Sagar Ayi on 11/1/19.
//  Copyright © 2019 Northeastern. All rights reserved.
//

import WatchKit
import HealthKit
import CoreLocation

class MainViewController: WKInterfaceController  {
    

    @IBOutlet weak var hearRateLabel: WKInterfaceLabel!
    
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stepsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stepsCounterLabel: WKInterfaceLabel!
    
    var currentHeartBeat : Double = 0
    
    var locationManager: CLLocationManager = CLLocationManager()
    var mapLocation: CLLocationCoordinate2D?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("AWAKE")
        WorkoutTracking.authorizeHealthKit()
        WorkoutTracking.shared.startWorkOut()
        WorkoutTracking.shared.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
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
    
    @IBAction func dropButton() {
        currentHeartBeat = currentHeartBeat + -30
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
        heartRateCountLabel.setText("\(heartRate + currentHeartBeat) BPM")
    }
}

extension MainViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
        let currentLocation = locations[0]
        let lat = currentLocation.coordinate.latitude
        let long = currentLocation.coordinate.longitude
        print("Lat is \(lat) , Long is \(long)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
