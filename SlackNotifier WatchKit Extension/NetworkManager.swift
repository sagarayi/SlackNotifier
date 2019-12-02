//
//  NetworkManager.swift
//  SlackNotifier WatchKit Extension
//
//  Created by Rajath Kashyap on 11/1/19.
//  Copyright © 2019   . All rights reserved.
//

import WatchKit

class NetworkManager: NSObject {

    var serverURL:URL = URL.init(string:"http://10.0.0.100:8080/java-websocket/rest/health/postData/")!
//        "http://13.59.88.20:8090/java-websocket/rest/health/postData")!
    
    func sendPersonData(personData: Data, user: String){
        let headers = [
          "content-type": "application/json",
          "cache-control": "no-cache",
        ]
        serverURL.appendPathComponent(user)
        var request = URLRequest.init(url: serverURL)
        request.httpMethod = "POST"
        request.httpBody = personData
        request.allHTTPHeaderFields = headers
        
        let requestTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response.debugDescription)
        }
        
        requestTask.resume()
    }
}
