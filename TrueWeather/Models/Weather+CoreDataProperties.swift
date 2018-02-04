//
//  Weather+CoreDataProperties.swift
//  TrueWeather
//
//  Created by rohit on 2/3/18.
//  Copyright © 2018 Rohit. All rights reserved.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var cityID: Int64
    @NSManaged public var cityName: String?
    @NSManaged public var humidity: Int16
    @NSManaged public var iconUrl: String?
    @NSManaged public var temperature: Float
    @NSManaged public var tempMax: Float
    @NSManaged public var tempMin: Float
    @NSManaged public var weatherSummary: String?

}
