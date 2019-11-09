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
    
    func sendPersonData(personData: Data){
        var request = URLRequest.init(url: serverURL)
        request.httpMethod = "POST"
        request.httpBody = personData
        
        let requestTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response.debugDescription)
        }
        
        requestTask.resume()
    }
}
