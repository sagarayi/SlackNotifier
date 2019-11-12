//
//  MainViewController.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Rajath Kashyap on 11/1/19.
//  Copyright © 2019   . All rights reserved.
//

import WatchKit
import HealthKit
import CoreLocation

class MainViewController: WKInterfaceController  {
    
    @IBOutlet weak var hearRateLabel: WKInterfaceLabel!
    
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stepsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stepsCounterLabel: WKInterfaceLabel!
    
    var currentHeartRate: Double = 0
    var currentStepCount: Double = 0
    var lat : Double = 0
    var longitude : Double = 0
    var isMoving: Bool = false
    
    
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
        
//        var store = HKHealthStore.init()
        
        
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
//        currentHeartBeat = currentHeartBeat + -30
        buildDataAndSendIt()
    }
}

extension MainViewController: WorkoutTrackingDelegate {
    func didReceiveHealthKitStepCounts(_ stepCounts: Double) {
        if (stepCounts > 0){
            stepsCounterLabel.setText("\(stepCounts) steps")
            currentStepCount = stepCounts
            isMoving = true
        }
    }
    
    func didReceiveHealthKitHeartRate(_ heartRate: Double) {
        currentHeartRate = heartRate
        heartRateCountLabel.setText("\(heartRate + currentHeartBeat) BPM")
    }
}

extension MainViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations[0]
        lat = currentLocation.coordinate.latitude
        longitude = currentLocation.coordinate.longitude
        print("Lat is \(lat) , Long is \(longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MainViewController{
    private func buildDataAndSendIt(){
        var mapper = ActivityMapper()
//        mapper.makeCode(string: <#T##String#>)
        var type = WorkoutTracking.shared.workoutBuilder.workoutConfiguration.activityType
        print("he is \(type.rawValue)")
        let personID = 00000000000
        let currentTimeStamp = getCurrentTimeStampInISOFormat()
        let locationData = JsonFields.PersonJSONData.coordinate(lat: lat, long: longitude)
        let jsonValues = JsonFields.PersonJSONData(id: personID,
                                                   timeStamp: currentTimeStamp,
                                                   heartRate: currentHeartRate,
                                                   steps: currentStepCount,
                                                   isMoving: isMoving,
//                                                   activityType: type.
                                                   location: locationData)
        let encoder = JSONEncoder()
        do{
            let data = try encoder.encode(jsonValues)
            let networkManager = NetworkManager()
            networkManager.sendPersonData(personData: data)
        }
        catch{
            print("Error encoding values to JSON")
        }
        
        
    }
    
    private func getCurrentTimeStampInISOFormat()-> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
