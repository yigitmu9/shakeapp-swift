//
//  ViewController.swift
//  accelerometer3
//
//  Created by Yiğit Mutlu on 12.05.2022.
//

import UIKit
import FirebaseDatabase
import CoreMotion
import Foundation
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //var currentMaxAccelX: Double = 0.0
    //var currentMaxAccelY: Double = 0.0
    //var currentMaxAccelZ: Double = 0.0
    var currentAccelX: Double = 0.0
    var currentAccelY: Double = 0.0
    var currentAccelZ: Double = 0.0
    var currentLat: Double = 0.0
    var currentLong: Double = 0.0
    var currentSubLocality: String = "currentSubLocality"
    var currentLocality: String = "currentLocality"
    var currentCity: String = "currentCity"
    var currentCountry: String = "currentCountry"
    var currentDeviceName: String = "currentDeviceName"
    var recordAccel: Double = 0.0
    //var currentStatus: String = "Stopped"

    

    
    var motionManager = CMMotionManager()
    let locationManager = CLLocationManager()

    @IBOutlet weak var accX: UILabel?
    @IBOutlet weak var accY: UILabel?
    @IBOutlet weak var accZ: UILabel?
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var loc2Label: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recStatusLabel: UILabel!
    @IBOutlet weak var subLocalityLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    

    
    

    private let database = Database.database().reference()
    
    //let currentDateTime = Date()

    
    override func viewDidLoad() {
        

        
        //currentMaxAccelX = 0.0
        //currentMaxAccelY = 0.0
        //currentMaxAccelZ = 0.0
        currentAccelX = 0.0
        currentAccelY = 0.0
        currentAccelZ = 0.0
        currentLat = 0
        currentLong = 0
        currentSubLocality = "currentSubLocality"
        currentLocality = "currentLocality"
        currentCity = "currentCity"
        currentCountry = "currentCountry"
        currentDeviceName = "currentDeviceName"
        
            motionManager.accelerometerUpdateInterval = 0.01
        
            motionManager.startAccelerometerUpdates(to: OperationQueue.current! , withHandler: { (AccelerometerData : CMAccelerometerData? , error) -> Void
                        
                        in
                        
                        self.outputAccelerationData(acceleration: (AccelerometerData?.acceleration)!)
                        if (error != nil){
                            
                            print("\(String(describing: error))")
                        }
                        
                        
                        
                        } )
        

                locationManager.requestWhenInUseAuthorization()
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.startUpdatingLocation()
                }
        

        recordButton.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        

        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    
    
        
        func outputAccelerationData(acceleration: CMAcceleration) {
            accX?.text = "\(acceleration.x) G"
            currentAccelX = acceleration.x
            /*
            if fabs(acceleration.x) > fabs(currentMaxAccelX) {
                currentMaxAccelX = acceleration.x
            }
            */
            accY?.text = "\(acceleration.y) G"
            currentAccelY = acceleration.y
            /*
            if fabs(acceleration.y) > fabs(currentMaxAccelY) {
                currentMaxAccelY = acceleration.y
            }
            */
            accZ?.text = "\(acceleration.z) G"
            currentAccelZ = acceleration.z
            /*
            if fabs(acceleration.z) > fabs(currentMaxAccelZ) {
                currentMaxAccelZ = acceleration.z
            }
            
            maxAccX?.text = "\(currentMaxAccelX) G"
            maxAccY?.text = "\(currentMaxAccelY) G"
            maxAccZ?.text = "\(currentMaxAccelZ) G"
             */
            
            // G unit = gravitational force = 9.81 m/s^2
            
            saveToDatabase()
            
            
            
            
            
            //hour.text = "\(currentDateTime)"
            
           
            
            
        }
    
    @objc private func startRecord() {
        recordAccel = 1
        recStatusLabel.text = "Accelerometer - Recording"
    }
    
    
    @objc private func stopRecord() {
        recordAccel = 0
        recStatusLabel.text = "Accelerometer - Stopped"
    }
    
    
    
    
    
    func saveToDatabase() {
        /*
        let asbX = abs(currentAccelX)
        let asbY = abs(currentAccelY)
        let asbZ = abs(currentAccelZ)
        let limitAsbAccelX = abs(limitAccelX)
        let limitAsbAccelY = abs(limitAccelY)
        let limitAsbAccelZ = abs(limitAccelZ)
        if fabs(asbX) > limitAsbAccelX || fabs(asbY) > limitAsbAccelY  || fabs(asbZ) > limitAsbAccelZ {
            addNewEntry()
         */
        
        if recordAccel == 1 {
            addNewEntry()
        }
        
        else {
            return
        }
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let location = locations[0]
        locLabel.text = "\(locValue.latitude)"
        loc2Label.text = "\(locValue.longitude)"
        currentLat = locValue.latitude
        currentLong = locValue.longitude
        currentDeviceName = UIDevice.current.name


        
        
        CLGeocoder() .reverseGeocodeLocation(location) { (placemark, error) in
        if error != nil
            {
        print ("THERE WAS AN ERROR")
        }
        else
        {
        if let place = placemark?[0]
            {
            if let checker = place.locality {
                self.subLocalityLabel.text = "\(place.subLocality!)"
                self.localityLabel.text = "\(place.locality!)"
                self.cityLabel.text = "\(place.administrativeArea!)"
                self.countryLabel.text = "\(place.country!)"

            }
            self.currentSubLocality = place.subLocality!
            self.currentLocality = place.locality!
            self.currentCity = place.administrativeArea!
            self.currentCountry = place.country!
            
        }

            
        }
            
            
        }
        
    }
   
    
   @objc private func addNewEntry() {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat="dd-MM-yyyy";
       dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss:SS";
       let currentDateTime = dateFormatter.string (from: Date())
       let object: [String: Any] = [
           "accx" : "\(currentAccelX)",
           "accy" : "\(currentAccelY)",
           "accz" : "\(currentAccelZ)",
           "date" : currentDateTime,
           "coordinates" : "\(currentLat) \(currentLong)",
           "place" :  "\(currentSubLocality)/\(currentLocality)/\(currentCity)/\(currentCountry)",
           "device" : "\(currentDeviceName)",
       ]

       database.child("\(currentDeviceName)/\(currentDateTime)").setValue(object)
       //"something_\(Int.random(in:0..<10000))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}



