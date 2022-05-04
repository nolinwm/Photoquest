//
//  QuestMapViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit
import MapKit

class QuestMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var photos = [Photo]()
    var initialPhotoIndex = 0
    var selectedAnnotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        for photo in photos {
            guard let coordinate = photo.coordinate else { continue }
            let annotation = MKPointAnnotation()
            annotation.title = photo.name
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        
        setupMapView()
    }
    
    func setupMapView() {
        var coordinate: CLLocationCoordinate2D?
        
        // Check if the photo that the map button was tapped on has coordinates, if not, use the first available photo's coordinates.
        if photos[initialPhotoIndex].coordinate != nil {
            coordinate = photos[initialPhotoIndex].coordinate
        } else {
            for photo in photos {
                if photo.coordinate != nil {
                    coordinate = photo.coordinate
                    break
                }
            }
        }
        
        // If no photos have coordinates, return so the map opens on it's default region.
        guard let coordinate = coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 75000, longitudinalMeters: 75000)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Photo Annotation")
        annotationView.markerTintColor = UIColor(named: "CustomTint")
        annotationView.glyphImage = UIImage(systemName: "photo")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.selectedAnnotation = view.annotation
        performSegue(withIdentifier: "segueToAnnotation", sender: self)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapAnnotationViewController {
            guard let selectedAnnotation = selectedAnnotation else { return }
            vc.photo = photos.first {
                $0.name == selectedAnnotation.title
            }
        }
    }
}
