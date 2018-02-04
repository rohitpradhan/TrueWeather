//
//  WeatherListViewController.swift
//  TrueWeather
//
//  Created by rohit on 2/3/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import UIKit

class WeatherListViewController: UITableViewController {
    
    //MARK:- Variables
    let TempCellIdentifier = "TempDetailsCell"
    var dataFetchTimer: Timer?
    var activityIndicator: UIActivityIndicatorView!
    lazy var viewModel: WeatherListViewModel = {
        return WeatherListViewModel()
    }()
    
    //MARK:- ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
    }
    
    deinit {
        stopTimers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK:- Activity Indicator
    
    /**
     This method creates and show the Activity indicator which is required to show when async is made.
     */
    func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle =
            .gray
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            window.addSubview(activityIndicator)
            window.backgroundColor = .white
            activityIndicator.startAnimating()
        }
    }
    
    /**
     This method hides Activity indicator which is shown earlier on async call.
     */
    func hideActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    /**
     This method does initial work such as setting closure to all closer properties of viewmodel. This closures gets called when loading status is updated, data is stored in the cell model array or error is occured.
     This method also starts the timer for fetching weather data on specified intervals.
     */
    func initViewModel() {
        
        viewModel.updateLoadingStatus = {
            
            DispatchQueue.main.async {
                [weak self] () in
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.showActivityIndicator()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 0.0
                    })
                }else {
                    self?.hideActivityIndicator()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure =  {
            [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.showAlertClosure =  {
            [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        startDataFetchTimer()
        
    }
    
    //MARK:- Timer
    /**
     This method is used to start timer which triggers web API call for weather
     */
    func startDataFetchTimer() {
        //should start only one timer
        guard dataFetchTimer == nil else {
            return
        }
        let fiveMinutes: Double = 300
        dataFetchTimer = Timer.scheduledTimer(timeInterval: fiveMinutes, target: self, selector: (#selector(self.executeFetch)), userInfo: nil, repeats: true)
        dataFetchTimer?.fire()
    }
    
    /**
     This method is stops the timer which triggers web API call for weather
     */
    func stopTimers() {
        if let timer = dataFetchTimer, timer.isValid == true {
            dataFetchTimer?.invalidate()
        }
    }
    
    /**
     This method is selector which get called on dataFetchTimer interval.
     */
    @objc func executeFetch() {
        viewModel.initFetch()
    }
    
    //MARK:- Navigation
    /**
     This method is used to navigate to weather details screen
     - parameter indexPath: Selected tableview indexpath
     */
    private func navigateToDetailVC(indexPath: IndexPath) {
        
        let weatherlistDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "WeatherlistDetailsIdentifier") as! WeatherlistDetailsViewController
        let cellModel = viewModel.getModel(at: indexPath)
        weatherlistDetailsViewController.viewModel = cellModel.detailModel
        navigationController?.pushViewController(weatherlistDetailsViewController
            , animated: true)
    }
    
    /**
     Show alert with message
     - parameter message: Message to show
     */
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - TableViewDataSource
extension WeatherListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TempCellIdentifier, for: indexPath) as! TempDetailsCell
        let cellModel = viewModel.getModel(at: indexPath)
        cell.labelCity.text = cellModel.city
        cell.labelTemperature.text = cellModel.temperature
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToDetailVC(indexPath: indexPath)
    }
    
}

//MARK:- Custom Cell
class TempDetailsCell: UITableViewCell {
    
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    
}
