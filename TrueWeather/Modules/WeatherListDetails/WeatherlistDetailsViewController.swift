//
//  WeatherlistDetailsViewController.swift
//  TrueWeather
//
//  Created by rohit on 2/1/18.
//  Copyright © 2018 Rohit. All rights reserved.
//

import UIKit
import SDWebImage

class WeatherlistDetailsViewController: UIViewController {
    
    //MARK:- Variables
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTempreture: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMinTemp: UILabel!
    @IBOutlet weak var labelMaxTemp: UILabel!
    @IBOutlet weak var labelHumidity: UILabel!
    var viewModel: WeatherCellDetailViewModel!
    
    //MARK:- ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    //MARK:- UI Setup
    /**
     This method sets all the viewmodel properties to the UI elements
     */
    private func updateUI() {
        labelTempreture.text = viewModel.temperature
        labelTitle.text = viewModel.weatherTitle
        labelMinTemp.text = viewModel.minTemperature
        labelMaxTemp.text = viewModel.maxTemperature
        labelHumidity.text = viewModel.humidity
        navigationItem.title = viewModel.city
        imageViewIcon.sd_setImage(with: URL(string: viewModel.weatherImageUrl)) { (image, error, type, url) in
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
