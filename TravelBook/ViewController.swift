//
//  ViewController.swift
//  TravelBook
//
//  Created by Sümeyra Demirtaş on 4.06.2024.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }


}

