//
//  APIService.swift
//  TrueWeather
//
//  Created by rohit on 2/1/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(String)
}

class APIService {
    
    private var cityID = ""
    private var APIKey: String {
        if let url = Bundle.main.url(forResource:"Info", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let swiftDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                let apiKey = swiftDictionary["APIKey"] as! String
                return apiKey
            } catch {
                return ""
            }
        }
        return ""
    }
    
    var endpoint: String {
        return "http://api.openweathermap.org/data/2.5/weather?id=\(cityID)&units=metric&APPID=\(APIKey)"
    }
    
    
    /**
     Call Weather API for the given cityID using NSURLSession
     - parameter cityID: city identifier
     - parameter completion: gets called when received response from Web API
     */
    func fetchWeatherDetails(for cityID: String, completion: @escaping (Result<[String: Any]>) -> Void ) {
        self.cityID = cityID
        
        let urlString = endpoint
        
        guard let url = URL(string: urlString) else { return completion(.error("Invalid URL, we can't update your feed")) }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { return completion(.error(error!.localizedDescription)) }
            guard let data = data else { return completion(.error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: Any] {
                    
                    DispatchQueue.main.async {
                        completion(.success(json))
                    }
                }
            } catch let error {
                return completion(.error(error.localizedDescription))
            }
        }.resume()
    }
    
}
