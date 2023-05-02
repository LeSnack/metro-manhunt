//
//  ContentView.swift
//  Metro_Manhunt
//
//  Created by Zac Whales on 2/5/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -27.470125, longitude: 153.021072), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .ignoresSafeArea()
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Turn on Location Manager")
        }
    }
    
    private func checkLocationAuthorisation() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Location Restricted")
            case .denied:
                print("Location Has Been Denied in Settings")
            case .authorizedAlways,.authorizedWhenInUse:
                break
            @unknown default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager) {
        checkLocationAuthorisation()
    }
}
