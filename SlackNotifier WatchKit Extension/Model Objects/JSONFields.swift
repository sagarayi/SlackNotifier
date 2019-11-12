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
        var id: Int
        var timeStamp: String
        
        var heartRate: Double
        var steps: Double
        var isMoving: Bool
//        var activityType:String
    
        struct coordinate:Codable {
            var lat: Double
            var long:Double
        }
        var location: coordinate

    }
    
}
