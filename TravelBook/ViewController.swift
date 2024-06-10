//
//  ViewController.swift
//  TravelBook
//
//  Created by Sümeyra Demirtaş on 4.06.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    var chosenPlace = ""
    var chosenPlaceId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    

    
    
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
        
        if chosenPlace != "" {
            
            //CoreData
            
            saveButton.isHidden = true
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            
            //fetch
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = chosenPlaceId!.uuidString
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "id = %@", idString) //adding filter
            
            
            do {
               let results = try context.fetch(request)
                
                if results.count > 0 { //eger gercekten bunun icinde bir sey varsa
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let comment = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = comment
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                }

            } catch{
                print("error")
            }
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = true
            nameText.text = ""
            commentText.text = ""
        }
        

    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if chosenPlace == "" {
            //CLLocation enlem ve boylam barindiran obje.
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) //span = zoom seviyesi
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { //kullanicinin yerinin pin ile gostermek istemiyoruz
            return nil
        }
    
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true // bir baloncukla birlikte extra bilgi gosterebildigimiz yer
            pinView?.tintColor = UIColor.black // annotationlar normalde kirmizi ya, bununla renk degistirebiliyoruz
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) // detay gosterecegim bir buton
            pinView?.rightCalloutAccessoryView = button //sag tarafta gosterilecek gorunumde bu button u goster
            
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if chosenPlace != ""{ // bir secilmis latitude ve longitude um var demektir.
            
            
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                //closure
                
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        
                        let newPlacemark =  MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark) //navigasyonu acabilmek icin mapitem olusturmak gerekiyor. onun icin de placemark denilen obje gerekiyor. bu objeyi de reverseGeocodeLocation ile aliyoruz
                        
                        item.name = self.annotationTitle
                        
                        let launchOption = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]  //hangi aracla gostereyim
                        
                        item.openInMaps(launchOptions: launchOption)
                        
                    }
                }
                
                
                
            } //CLGeocoder koordinatlar ve yerler arasinda baglanti kurmamiza yarayan sinif
        }
    }
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        
        //Attributes
        
        newPlace.setValue(nameText.text!, forKey: "title")
        newPlace.setValue(commentText.text!, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true) //bir onceki ViewController a goturur
        
        
    }
    

}

