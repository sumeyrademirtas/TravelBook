//
//  ViewController.swift
//  TravelBook
//
//  Created by Sümeyra Demirtaş on 4.06.2024.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //en iyi bu buluyor ama cok pil yiyor.
        locationManager.requestWhenInUseAuthorization() //kullanici uygulamayi kullanirken konumuna erismek icin
        locationManager.startUpdatingLocation() //kullanicinin konumunu bununla birlikte almaya basliyoruz
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)

    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //CLLocation enlem ve boylam barindiran obje.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) //span = zoom seviyesi
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }


}

