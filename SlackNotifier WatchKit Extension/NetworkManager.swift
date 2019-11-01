//
//  NetworkManager.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Sagar Ayi on 11/1/19.
//  Copyright © 2019 Northeastern. All rights reserved.
//

import WatchKit

class NetworkManager: NSObject {

    let serverURL:URL = URL.init(string: "https://google.com")!
    
    func sendHeartRateData(heartRate:Double){
        var request = URLRequest.init(url: serverURL)
        request.httpMethod = "POST"
        
        let requestTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //do something when you get a response
        }
        
        requestTask.resume()
    }
}
