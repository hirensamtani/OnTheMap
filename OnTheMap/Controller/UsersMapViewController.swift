//
//  UsersMapViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 21/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import MapKit


class UsersMapViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    var annotations = [MKPointAnnotation]()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        refreshData()
    }


    
    
    func refreshData()
    {
        
        self.showActivityIndicator(self.activityIndicator)
        UdacityUsersModel.sharedInstance.loadUsersData { (success, error) in
            guard (error == nil) else {
                print("\(error!)")
                self.showInfo(withTitle: "Error", withMessage: error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.removeAnnotations()
                self.reloadData()
            }
            self.hideActivityIndicator(self.activityIndicator)
        }
    }
    private func removeAnnotations()
    {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
    }
    
    func reloadData()
    {
        
        let udacityUsers = UdacityUsersModel.sharedInstance.udacityUsers
        for user in udacityUsers {
            let lat = CLLocationDegrees(user.latitude!)
            let long = CLLocationDegrees(user.longitude!)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = user.firstName!
            let last = user.lastName!
            let mediaURL = user.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {

            if let toOpen = view.annotation?.subtitle! {
                openWithSafari(toOpen)
    
            }
        }
    }
    
}
