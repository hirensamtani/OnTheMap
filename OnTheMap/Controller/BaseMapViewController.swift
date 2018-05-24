//
//  BaseMapViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 23/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BaseMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let subtitle = view.annotation?.subtitle else  {
                showInfo(withMessage: "No link defined.")
                return
            }
            guard let link = subtitle else {
                showInfo(withMessage: "No link defined.")
                return
            }
            openWithSafari(link)
        }
    }
    
    
    
    
    
    
}
