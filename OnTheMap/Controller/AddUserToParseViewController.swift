//
//  AddUserToParseViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 22/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import CoreLocation



class AddUserToParseViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textFieldLocation: UITextField!
    
    
    @IBOutlet weak var textFieldLink: UITextField!
    
    
    @IBOutlet weak var textFieldFirstName: UITextField!
    
    
    @IBOutlet weak var textFieldLastName: UITextField!
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var buttonFindLocation: UIButton!
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    
    
    
    var isNewUser: Bool? = false
    var udacityUser: UdacityUser?
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    
    lazy var geocoder = CLGeocoder()
    var coordinateDerived : CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showActivityIndicator(self.activityIndicator)
        
        UdacityClientManager.sharedInstance.getStudentLocationFromParse { (studentInfo, studentFound, error) in
           
            
            
            guard (error == nil) else {
                print("\(error!)")
                self.showInfo(withTitle: "Error", withMessage: error!.localizedDescription)
                return
            }
            
            if studentFound {
                DispatchQueue.main.async {
                    self.udacityUser = UdacityUser(userInformation: studentInfo!)
                    self.loadStudentInfo()
                }
                
            } else {
                self.isNewUser = true;
            }
            self.hideActivityIndicator(self.activityIndicator)
        }
        
        textFieldLocation.delegate = self
        textFieldLink.delegate = self
        textFieldFirstName.delegate = self
        textFieldLastName.delegate = self
        
        
    }
    
    private func loadStudentInfo()
    {
        textFieldFirstName.text = udacityUser!.firstName
        textFieldLastName.text = udacityUser!.lastName
        
        textFieldLink.text = udacityUser!.mediaURL
        textFieldLocation.text = udacityUser!.mapString
        currentLocation = CLLocation(latitude: udacityUser!.latitude!, longitude: udacityUser!.longitude!)
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
         scrollView.setContentOffset(textField.frame.origin, animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textFieldLocation.resignFirstResponder()
        textFieldLink.resignFirstResponder()
        textFieldFirstName.resignFirstResponder()
        textFieldLastName.resignFirstResponder()
        
        
        if (textField == textFieldLocation) {
            textFieldLink.becomeFirstResponder()
        }
        else if (textField == textFieldLink) {
            textFieldFirstName.becomeFirstResponder()
           }
        else if (textField == textFieldFirstName) {
            textFieldLastName.becomeFirstResponder()
        }
        else if (textField == textFieldLastName) {
            buttonFindLocation.sendActions(for: UIControlEvents.touchUpInside)
            scrollView.setContentOffset(buttonFindLocation.frame.origin, animated: true)
        }

       
        
        return true
    }
    
    
    
    func enableUI(views: UIControl..., enable: Bool) {
        DispatchQueue.main.async {
            for view in views {
                view.isEnabled = enable
            }
        }
    }
    
    private func enableControllers(_ enable: Bool) {
        self.enableUI(views: textFieldLocation, textFieldLink, textFieldFirstName, textFieldLastName ,buttonFindLocation, enable: enable)
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func find(_ sender: Any) {
        
        let location = textFieldLocation.text!
        let link = textFieldLink.text!
        let firstName = textFieldFirstName.text!
        let lastName = textFieldLastName.text!
        
        if location.isEmpty || link.isEmpty || firstName.isEmpty || lastName.isEmpty {
            showInfo(withMessage: "All fields are required.")
            return
        }
        guard let url = URL(string: link), UIApplication.shared.canOpenURL(url) else {
            showInfo(withMessage: "Please provide a valid link.")
            return
        }
        geocode(location: location)
        
        
        
        
    }
    
    private func geocode(location: String) {
        enableControllers(false)
        self.showActivityIndicator(self.activityIndicator)
        geocoder.geocodeAddressString(location) { (placemarkers, error) in
            
            self.enableControllers(true)
           self.hideActivityIndicator(self.activityIndicator)

            if let error = error {
                self.showInfo(withTitle: "Error", withMessage: "Unable to Forward Geocode Address (\(error.localizedDescription))")
            } else {
                var location: CLLocation?

               
                if let placemarks = placemarkers, placemarks.count > 0 {
                    location = placemarks.first?.location
                }

                if let location = location {
                    self.syncStudentLocation(location.coordinate)
                } else {
                    self.showInfo(withMessage: "No Matching Location Found")
                }
            }
        }
    }
    
    
    
        private func syncStudentLocation(_ coordinate: CLLocationCoordinate2D) {
            self.enableControllers(true)
//            print("hbs lov coordi ",coordinate.latitude)
            coordinateDerived = coordinate
            
            performSegue(withIdentifier: "mapPinSegue", sender: self)

        }
    
    
    
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> UdacityUser {
        
        var studentInfo = [
            ParseUserInfoKeys.UniqueKey : UdacityClientManager.sharedInstance.udacityUserID!,
            ParseUserInfoKeys.FirstName : textFieldFirstName.text!,
            ParseUserInfoKeys.LastName : textFieldLastName.text!,
            ParseUserInfoKeys.MapString : textFieldLocation.text!,
            ParseUserInfoKeys.MediaURL : textFieldLink.text!,
            ParseUserInfoKeys.Latitude : coordinate.latitude,
            ParseUserInfoKeys.Longitude : coordinate.longitude,
            ParseUserInfoKeys.ObjectID : ""
            ] as [String : Any]
        
        if !(isNewUser!) {
            studentInfo.updateValue(udacityUser!.objectID, forKey: ParseUserInfoKeys.ObjectID)
        }
        
        let studentUser = UdacityUser.init(userInformation: studentInfo as [String : AnyObject])
        
        
        return studentUser!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapPinSegue" {
            if let mapPinLocationController = segue.destination as? MapPinLocationViewController {
                mapPinLocationController.studentInformation = buildStudentInfo(coordinateDerived!)
                mapPinLocationController.isNewUser = isNewUser
        }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
//        keyboardMoveListener.subscribe(view: view, elements: [textFieldLastName,textFieldFirstName])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
//        keyboardMoveListener.unsubscribe()
        
    }
    
    
    
    
}
