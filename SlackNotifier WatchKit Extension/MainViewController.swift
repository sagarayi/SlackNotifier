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
    var isDropped = false
    
    var locationManager: CLLocationManager = CLLocationManager()
    var mapLocation: CLLocationCoordinate2D?
    
    var webSocketManager:WebSocketManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
//         Configure interface objects here.
        print("AWAKE")
        WorkoutTracking.authorizeHealthKit()
        WorkoutTracking.shared.startWorkOut()
        WorkoutTracking.shared.delegate = self

//        var store = HKHealthStore.init()


        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        
        let timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.buildDataAndSendIt), userInfo: nil, repeats: true)

        
//        let timer = Timer(timeInterval: 0.1, repeats: true) { _ in  self.buildDataAndSendIt()}
        
        
//        webSocketManager = WebSocketManager(url: URL(string:
////            "wss://echo.websocket.org/")!)
//            "ws://13.59.88.20:8090/java-websocket-0.0.1-SNAPSHOT/health/akshay")!)
//        webSocketManager.delegate = self
//
//        webSocketManager.connect()
        
//        webSocketManager.send(text: "test")
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
        if (isDropped){
            if (currentHeartRate+currentHeartBeat < 70){
            currentHeartBeat = 0
                isDropped = false
            }
        }
        else {
            currentHeartBeat =  -30
            isDropped = true
        }
//        currentHeartBeat = currentHeartBeat < 50 ?  currentHeartBeat-30 : currentHeartBeat+30
//        buildDataAndSendIt()
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
    @objc private func buildDataAndSendIt(){
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
                                                   location: locationData)
        let encoder = JSONEncoder()
        do{
//            let jsonData = try? JSONSerialization.data(withJSONObject: jsonValues)
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

extension MainViewController: WebSocketConnectionDelegate{
    func onConnected(connection: WebSocketConnection) {
        print("Connected")
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("Disconnected")
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print("Connection error")
    }
    
    func onMessage(connection: WebSocketConnection, text: String) {
//        if (text == "Watch connected"){
            
            let  json: [String:String] = ["id":"1","messageType":"TEXT","timeStamp":"1573783202833","from":"rajat","to":"akshay","content":"test message","receiverType":"USER"]
                do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
//                    connection.send(data:jsonData)

                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                // here "decoded" is of type `Any`, decoded from JSON data
                    let jsonString = String(data:jsonData, encoding: .ascii)
                    connection.send(text: jsonString!)
                // you can now cast it with the right type
                    if let dictFromJSON = decoded as? [String:String] {
//                        connection.send(text: dictFromJSON)
                }
            } catch {
                print(error.localizedDescription)
            }
            
//        }
        print("Got message \(text)")
//        connection.send(text: "ok")
    }
    
    func onMessage(connection: WebSocketConnection, data: Data) {
        print("Got Data")
    }
    
    
}
