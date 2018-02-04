//
//  CoreDataService.swift
//  TrueWeather
//
//  Created by rohit on 2/2/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
 
        let container = NSPersistentContainer(name: "TrueWeather")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var managedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        return context
    }()
    
    // MARK: - Core Data Saving support
    /**
     This method is used to save the changes for managed object context to persistance store(SQLite)
     */
    static func saveContext () {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /**
     This method is used to fetch all weather objects from the persistance store.
     - Returns: array of weather objects(NSManagedObject)
     */
    static func fetchAllWeatherRecords() -> [Weather]? {
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results
        } catch {
            return nil
        }
    }
    
    /**
     This method parses the data received from WebAPI and create Weather object and store it in persistance store.Before saving it checks if the temprature of that city with the cityID is updated or not. It not updated then it will not store. If there is no data already then it created Weather object and store.
     - parameter json: object received from WebAPI
     */
    static func updateWeatherInfo(_ json: [String: Any]) {
        //fetch weather for Id
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        var weather: Weather!
        
        //get cityId and temperature
        if  let mainWeather = json[WeatherKeys.weatherTitle.rawValue]  as? [String: Any], let temperature = mainWeather[WeatherKeys.temperature.rawValue] as? Float,
            let cityID = json[WeatherKeys.id.rawValue]  as? Int64 {
            
            fetchRequest.predicate = NSPredicate(format: "cityID = %d", cityID)
            do {
                //fetch weather object with city
                let results = try managedObjectContext.fetch(fetchRequest)
                //always one object of city ID
                if results.count > 0 {
                    weather = results[0]
                } else {
                    weather = Weather(context: CoreDataService.managedObjectContext)
                }
            } catch {
                //fail to fetch
                return
            }
            
            //if temperature is same dont update
            guard temperature != weather.temperature else {
                return
            }
            
            //parse JSON to store
            if  let mainWeather = json[WeatherKeys.weatherTitle.rawValue]  as? [String: Any] {
                if let temperature = mainWeather[WeatherKeys.temperature.rawValue] as? Float,
                    let humidity = mainWeather[WeatherKeys.humidity.rawValue] as? Int16,
                    let minTemperature = mainWeather[WeatherKeys.minTemperature.rawValue] as? Float,
                    let maxTemperature = mainWeather[WeatherKeys.maxTemperature.rawValue] as? Float  {
                    
                    weather.temperature = temperature
                    //Warning: Added to test
                    
                    weather.humidity = humidity
                    weather.tempMin = minTemperature
                    weather.tempMax = maxTemperature
                }
            }
            
            //For readability, used multiple if let binding blocks
            if  let cityID = json[WeatherKeys.id.rawValue]  as? Int64,
                let cityName = json[WeatherKeys.cityName.rawValue]  as? String {
                weather.cityID = cityID
                weather.cityName = cityName
            }
            
            //For readability, used multiple if let binding blocks
            if let dataArray = json[WeatherKeys.weatherDetails.rawValue]  as? [[String: Any]] {
                let info = dataArray[0]
                let summary = info[WeatherKeys.weatherTitle.rawValue] as! String
                let imageID = info[WeatherKeys.weatherIcon.rawValue] as! String
                weather.weatherSummary = summary
                weather.iconUrl = "http://openweathermap.org/img/w/\(imageID).png"
            }
            
            //Save context
            do {
                try managedObjectContext.save()
            } catch {
                //fail to update
            }
        }
        
    }
    
}
