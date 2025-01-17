//
//  Location.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Rajath Kashyap on 11/9/19.
//  Copyright © 2019   . All rights reserved.
//

import WatchKit

class JsonFields: NSObject {
    
    struct PersonJSONData:Codable{
        var id: String
        var timeStamp: Double
        var heartRate: Double
        var steps: Double
        var isMoving: Bool
        var activityType:Int
        var lat: Double
        var long:Double
    }
    
}
