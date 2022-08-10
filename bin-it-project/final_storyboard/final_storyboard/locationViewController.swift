//
//  locationViewController.swift
//  final_storyboard
//
//  Created by Pippa Lother on 4/11/22.
//

import UIKit
import CoreLocation
import MapKit

class locationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
        override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            locationManager.delegate = self
            mapView.delegate = self
            locationManager.requestWhenInUseAuthorization()
            getAddress()
       }

       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           
           if status == .authorizedWhenInUse || status == .authorizedAlways{
               print("APP auth")
               locationManager.startUpdatingLocation()
           }
           if status == .notDetermined || status == .denied{
               //need to fix this to take them back to the main screen
               locationManager.requestWhenInUseAuthorization()
           }
           
       }
       
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           
           let myCurrLocation = CLLocationCoordinate2D(latitude:  (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
           
           let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
           
           let region = MKCoordinateRegion(center: myCurrLocation, span: span)
           
           mapView.setRegion(region, animated: true)
           
           locationManager.stopUpdatingLocation()
       }
    
        func getAddress(){
            let geoCoder = CLGeocoder()
            let recycle_plants = "Recycling Centers"

            geoCoder.geocodeAddressString(recycle_plants) { (placemarks, error) in
                guard let placemarks = placemarks, let location =
                        placemarks.first?.location
                else{
                  print("No recycling facility near you")
                    return
                }
                print(location)
                self.mapThis(destinationCoord: location.coordinate)
            }
        }
    
        func mapThis(destinationCoord: CLLocationCoordinate2D){
            let sourceCoordinate = (locationManager.location?.coordinate)!
            
            let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
            let destPlaceMark = MKPlacemark(coordinate: destinationCoord)
            
            let sourceItem = MKMapItem(placemark: sourcePlaceMark)
            let destItem = MKMapItem(placemark: destPlaceMark)
            
            let destinationRequest = MKDirections.Request()
            destinationRequest.source = sourceItem
            destinationRequest.destination = destItem
            destinationRequest.transportType = .automobile
            destinationRequest.requestsAlternateRoutes = true
            
            let directions = MKDirections(request: destinationRequest)
            directions.calculate {(response, error) in
                guard let response = response else{
                    if let error = error {
                        print("Direction request denied")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        
        return render
    }
       /*
       // MARK: - Navigation

       // In a storyboard-based application, you will often want to do a little preparation before navigation
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           // Get the new view controller using segue.destination.
           // Pass the selected object to the new view controller.
       }
       */


}
