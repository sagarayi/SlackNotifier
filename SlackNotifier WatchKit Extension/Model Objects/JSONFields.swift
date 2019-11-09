//
//  Location.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Sagar Ayi on 11/9/19.
//  Copyright © 2019 Northeastern. All rights reserved.
//

import WatchKit

class JsonFields: NSObject {

    struct PersonJSONData:Codable{
        var id: String
        var timeStamp: String
        
        var heartRate: Double
        var steps: Double
        var isMoving: Bool
    
        struct coordinate:Codable {
            var lat: Double
            var long:Double
        }
        var location: coordinate

    }
    
}
