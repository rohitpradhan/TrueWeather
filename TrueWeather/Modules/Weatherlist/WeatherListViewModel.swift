//
//  WeatherListViewModel.swift
//  TrueWeather
//
//  Created by rohit on 2/1/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import Foundation

enum CityID: String {
    case melbourne = "4163971"
    case sydney = "2147714"
    case brisbane = "2174003"
}

enum WeatherKeys: String {
    case temperature = "temp"
    case preasure = "pressure"
    case humidity = "humidity"
    case minTemperature = "temp_min"
    case maxTemperature = "temp_max"
    case id = "id"
    case cityName = "name"
    case weatherDetails = "weather"
    case weatherTitle = "main"
    case weatherIcon = "icon"
}

class WeatherListViewModel {
    
    //MARK:- Variables
    //model array reload closure
    var weatherCellModels: [WeatherCellViewModel] = [WeatherCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    //status isLoading
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    //ALertMessage
    var alertMessage: String? {
        didSet {
            showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return weatherCellModels.count
    }
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    var cityIds: [CityID] = [.melbourne, .sydney, .brisbane]
    let apiService: APIService
    
    //MARK:- Initializers
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    //MARK:- Utility Methods
    func getModel(at indexpath: IndexPath) -> WeatherCellViewModel {
        return weatherCellModels[indexpath.row]
    }
    
    /**
     This method is used Fetch weather details from the Web API and store the record in the coreData.
     */
    func initFetch() {
        
        let dispatchGroup = DispatchGroup()
        isLoading = true
        
        for cityID in cityIds {
            
            dispatchGroup.enter()
            apiService.fetchWeatherDetails(for: cityID.rawValue, completion: { [weak self] ( result ) in
                
                switch result {
                case .success(let data):
                    CoreDataService.updateWeatherInfo(data)
                    
                case .error( _):
                    DispatchQueue.main.async {
                        self?.alertMessage = "fail to get response"
                    }
                }
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            print("All functions complete 👍")
            self?.isLoading = false
            //Notify VC that data is updated
            if let weatherRecords = CoreDataService.fetchAllWeatherRecords() {
                self?.processFetchedWeatherObjects(weatherRecords)
            }
        }
    }
    
    /**
     This method is used to parse  array of the Weather (NSManangedObject) objects and convert this object in consumable WeatherCellViewModel and set to weatherCellModels array. On set of this array the reload closure gets called.
     - parameter objects: array of Weather (NSManangedObject)
     */
    private func processFetchedWeatherObjects(_ objects: [Weather]) {
        var cellViewModels = [WeatherCellViewModel]()
        
        for weather in objects {
            let weatherCellModel = creatCellViewModel(weather)
            cellViewModels.append(weatherCellModel)
        }
        
        weatherCellModels = cellViewModels
    }
    
    /**
     This method is used to parse the Weather (NSManangedObject) and convert this object in consumable WeatherCellViewModel. On set of this array the reload closure gets called.
     - parameter objects:  Weather (NSManangedObject)
     - returns: WeatherCellViewModel object with all directly assignable strings
     */
    private func creatCellViewModel(_ weather: Weather) -> WeatherCellViewModel {
        let humidity = "\(weather.humidity) %"
        let minTemperature = "\(weather.tempMin) °C"
        let maxTemperature = "\(weather.tempMin) °C"
        let weatherTitle = weather.weatherSummary ?? ""
        let weatherImageUrl = weather.iconUrl ?? ""
        let city = weather.cityName ?? ""
        let temperature = "\(weather.temperature) °C"
        let detailModel =  WeatherCellDetailViewModel(humidity: humidity, minTemperature: minTemperature, maxTemperature: maxTemperature, weatherTitle: weatherTitle, weatherImageUrl: weatherImageUrl, temperature: temperature, city: city)
        
        let weatherCellModel = WeatherCellViewModel(city: city, temperature: temperature, detailModel: detailModel)
        
        return weatherCellModel
    }
    
}

//MARK:- CellViewModel
struct WeatherCellViewModel {
    let city: String
    let temperature: String
    let detailModel: WeatherCellDetailViewModel
}

//MARK:- CellViewDetailModel
struct WeatherCellDetailViewModel {
    let humidity: String
    let minTemperature: String
    let maxTemperature: String
    let weatherTitle: String
    let weatherImageUrl: String
    let temperature: String
    let city: String
}

