//
//  MapModel.swift
//  ClassProject
//
//  Created by Aften.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

// Class that holds function for map functionality
final class MapModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion()
    @Published var stores: [BookstoreAnnotation] = []
    
    private let locationManager = CLLocationManager()
    
    // Values to control map zoom level
    private let searchRadius: CLLocationDistance = 3500
    private let zoomFactor: Double = 2
    
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Function to request user permissions
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            centerOnLocation(location)
        }
    }
    
    // Function to center on user location
    func centerOnUserLocation() {
        if let location = locationManager.location {
            centerOnLocation(location)
        }
    }
    
    // Function to zoom in on selected store by user
    func zoomToStore(_ store: BookstoreAnnotation) {
        let newSearchRadius = searchRadius / zoomFactor
        region = MKCoordinateRegion(center: store.coordinate, latitudinalMeters: newSearchRadius, longitudinalMeters: newSearchRadius)
    }
    
    
    private func centerOnLocation(_ location: CLLocation) {
        region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
    }
    
    // Function to find bookstores near user
    func findNearbyBookstores() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "bookstore"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let mapItems = response.mapItems
            self.stores = mapItems.map { store -> BookstoreAnnotation in
                let annotation = BookstoreAnnotation(name: store.name ?? "Unknown", coordinate: store.placemark.coordinate)
                return annotation
            }
        }
    }
    
    
    
}

// Class to handle map annotations
class BookstoreAnnotation: NSObject, Identifiable, MKAnnotation {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return name
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }
}

// Stuct to handle ui functionality of the map
struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var mapModel: MapModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Function to actually make the map view
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.addAnnotations(mapModel.stores)
        return mapView
    }
    
    // Function to update the ui view
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(mapModel.region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(mapModel.stores)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let reuseIdentifier = "StoreMarker"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? BookstoreAnnotation else {
                return
            }
            
            mapView.deselectAnnotation(annotation, animated: true)
            
            let alert = UIAlertController(title: "Bookstore", message: annotation.name, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
