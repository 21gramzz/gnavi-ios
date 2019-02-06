//
//  ViewController.swift
//  gnavi
//
//  Created by Taro Kimura on 2019/02/01.
//  Copyright © 2019 Taro Kimura. All rights reserved.
//


import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var rangeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 100
        locationManager?.startUpdatingLocation()
        inputText.delegate = self
        inputText.placeholder="Search Keyword"
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    //位置情報取得成功時に呼び出される
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,CLLocationCoordinate2DIsValid(newLocation.coordinate) else { return }
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        self.delegate.latitude = latitude!
        self.delegate.longitude = longitude!
        //print("latitude: \(latitude!) longitude: \(longitude!)")
    }
    
    @IBAction func searchButton(_ sender: Any) {
        if let inputText = inputText.text{
            self.delegate.searchKeyword=inputText
        }
    }
    
    //検索半径を設定
    @IBAction func sliderChanged(_ sender: UISlider) {
        print(Int(sender.value))
        switch Int(sender.value) {
        case 1:
            self.delegate.searchRange=1
            rangeLabel.text="検索半径300m"
        case 2:
            self.delegate.searchRange=2
             rangeLabel.text="検索半径500m"
        case 3:
            self.delegate.searchRange=3
             rangeLabel.text="検索半径1km"
        case 4:
            self.delegate.searchRange=4
             rangeLabel.text="検索半径2km"
        case 5:
            self.delegate.searchRange=5
             rangeLabel.text="検索半径3km"
        default:
            break
        }
    }
    
    //returnキーでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //TextField以外をタップでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


