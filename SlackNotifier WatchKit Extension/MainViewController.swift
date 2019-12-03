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
    
    let webSocketURL  = "ws://10.110.74.174:8080/java-websocket/health/"
    let currentUser = "akshay"
    //    "Apple_Watch_User"
    
    let authorisationKey = "isAuthorised"
    let groupIDKey = "groupID"
    
    
    var currentHeartBeat : Double = 0
    var isDropped = false
    
    var locationManager: CLLocationManager = CLLocationManager()
    var mapLocation: CLLocationCoordinate2D?
    
    var webSocketManager:WebSocketManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        initManagers()
        
        //        let _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.buildDataAndSendIt), userInfo: nil, repeats: true)
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
    
    func initWorkoutManager(){
        WorkoutTracking.authorizeHealthKit()
        WorkoutTracking.shared.startWorkOut()
        WorkoutTracking.shared.delegate = self
    }
    
    func initLocationManager(){
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    func initManagers(){
        initWorkoutManager()
        initLocationManager()
        if (self.isAuthorised()){
            initWebSocket(url: webSocketURL + currentUser)
        }
        
    }
    
    func initWebSocket(url:String){
        webSocketManager = WebSocketManager(url: URL(string:url)!)
        webSocketManager.delegate = self
        webSocketManager.connect()
    }
    
    func isAuthorised() -> Bool{
        return UserDefaults.standard.bool(forKey: authorisationKey)
    }
    
    func updateGroupID(groupID:String){
        let currentGroupID = UserDefaults.standard.string(forKey: groupIDKey)
        if (groupID != currentGroupID){
            UserDefaults.standard.set(groupID, forKey: groupIDKey)
            showAlertFor(user:groupID)
        }
    }
    
    func showAlertFor(user: String){
        let acceptAction = WKAlertAction(title: "Accept", style: .default, handler: {})
        
        let cancelAction = WKAlertAction(title: "Cancel", style: .cancel, handler: {})
        
        presentAlert(withTitle: "Tracking Alert", message: "\(user) would like to track your watch stats. Accept to track ?", preferredStyle: .alert, actions: [acceptAction,cancelAction])
    }
    
    @IBAction func dropButton() {
        if (isDropped){
            if (currentHeartRate+currentHeartBeat < 50){
                currentHeartBeat = 0
                isDropped = false
            }
        }
        else {
            currentHeartBeat =  -50
            isDropped = true
            if (UserDefaults.standard.string(forKey: groupIDKey) != nil){
                buildDataAndSendIt()
            }
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
    
    func gotPermission() {
        if (!self.isAuthorised()){
            UserDefaults.standard.set(true, forKey:authorisationKey)
            self.initManagers()
        }
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
        let groupID = UserDefaults.standard.string(forKey: groupIDKey)
        let currentTimeStamp = (NSDate().timeIntervalSince1970 * 1000.0).rounded()
//            NSDate().timeIntervalSince1970.
        //            getCurrentTimeStampInISOFormat()
//        let locationData = JsonFields.PersonJSONData.coordinate(lat: lat, long: longitude)
        isMoving = !isMoving
        let jsonValues = JsonFields.PersonJSONData(id: groupID!,
                                                   timeStamp: currentTimeStamp,
                                                   heartRate: currentHeartRate + currentHeartBeat,
                                                   steps: currentStepCount,
                                                   isMoving: isMoving,
                                                   activityType:Int(type.rawValue),
                                                   lat: lat,
                                                   long:longitude)
        let encoder = JSONEncoder()
        do{
            let data = try encoder.encode(jsonValues)
            let networkManager = NetworkManager()
            networkManager.sendPersonData(personData: data, user: currentUser)
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
        var error : NSError?
        let jsonData = text.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        //        let jsonDict: [String:String] = JSONSerialization.jsonObject(with: jsonData, options: [])
        //        if (text == "Watch connected"){
        
        //        let  json: [String:String] = ["id":"1","messageType":"TEXT","timeStamp":"1573783202833","from":"rajat","to":"akshay","content":"test message","receiverType":"USER"]
        //        do {
        //            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        //            // here "jsonData" is the dictionary encoded in JSON data
        //            //                    connection.send(data:jsonData)
        //
        do{
            let decoded = try JSONSerialization.jsonObject(with: jsonData!, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            //            let jsonString = String(data:jsonData, encoding: .ascii)
            //            connection.send(text: jsonString!)
            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:String] {
                if (dictFromJSON["error"]?.count == 0 ){
                    self.updateGroupID(groupID: dictFromJSON[self.groupIDKey]!)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        //        }
        print("Got message \(text)")
    }
    
    func onMessage(connection: WebSocketConnection, data: Data) {
        do{
            let decoded = try JSONSerialization.jsonObject(with: data, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            //            let jsonString = String(data:jsonData, encoding: .ascii)
            //            connection.send(text: jsonString!)
            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:String] {
                if (dictFromJSON["error"]?.count == 0 ){
                    self.updateGroupID(groupID: dictFromJSON[self.groupIDKey]!)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        print("Got Data")
    }
    
    
}
