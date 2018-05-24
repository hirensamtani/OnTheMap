//
//  MapPinLocationViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 23/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



class MapPinLocationViewController : BaseMapViewController {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var buttonFinish: UIButton!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var studentInformation: UdacityUser?
    var isNewUser: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        self.showActivityIndicator(self.activityIndicator)
        
        if let location = studentInformation {
            showLocations(location: location)
        }
        
    }
    
    
    
    @IBAction func cancelMapPinLocation(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func finish(_ sender: Any) {
        if let studentLocation = studentInformation {
            showNetworkOperation(true)
            
//            print(isNewUser)
            if isNewUser! {
                // POST
                UdacityClientManager.sharedInstance.postSudentLocationToParse(info: studentLocation, completionHandlerForPostStudentLocationToParse: { (success, error) in
                    DispatchQueue.main.sync {
                        self.showNetworkOperation(false)
                    }
                    self.handleSyncLocationResponse(error: error)
                })
            } else {
                // PUT
                UdacityClientManager.sharedInstance.updateStudentLocationToParse(info: studentLocation, completionHandlerForUpdateSudentLocationToParse: { (success, error) in
                    DispatchQueue.main.sync {
                        self.showNetworkOperation(false)
                    }
                    self.handleSyncLocationResponse(error: error)
                })
            }
        }
        
        
    }
    
    
    
    private func showLocations(location: UdacityUser) {
        
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = extractCoordinate(location: location) {
            let annotation = MKPointAnnotation()
            annotation.title = location.locationLabel
            annotation.subtitle = location.mediaURL 
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
            self.hideActivityIndicator(self.activityIndicator)
        }
    }
    
    private func extractCoordinate(location: UdacityUser) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }
    
    
    private func handleSyncLocationResponse(error: NSError?) {
        if let error = error {
            showInfo(withTitle: "Error", withMessage: error.localizedDescription)
        } else {
            showInfo(withTitle: "Success", withMessage: "Student Location updated!", action: {
                
//                var viewControllers = self.navigationController?.viewControllers
                
              
                self.performSegue(withIdentifier: "unwindToMapView", sender: self)
                
            })
            
        }
    }
    
    
    
    private func showNetworkOperation(_ show: Bool) {
       
//        DispatchQueue.main.sync {
            self.buttonFinish.isEnabled = !show
            self.mapView.alpha = show ? 0.5 : 1
            show ? self.showActivityIndicator(self.activityIndicator) : self.hideActivityIndicator(self.activityIndicator)
//        }
    }
    
    
    
    
}
