//
//  ContentView.swift
//  HelloMapSwiftUI
//
//  Created by 申潤五 on 2024/9/23.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @State private var searchResult:[MKMapItem] = []
    @State private var camPosition:MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var scale:CGFloat = 10
    @State private var mapType = "標準"
    @State private var searchKeyWord = ""
    @State private var userTrackingMode:MapUserTrackingMode = .follow
    @StateObject private var locationManagerDelegate:LocationDelegate = LocationDelegate()
    private var locationManager = CLLocationManager()
    let location = CLLocationCoordinate2D(
        latitude: 25.04729,
        longitude: 121.51756)
    @State private var region:MKCoordinateRegion =
    MKCoordinateRegion(center: CLLocationCoordinate2D(
        latitude: 25.04729,
        longitude: 121.51756),
                       span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01))
    
    
    let typesName = ["標準","衛星照片","混合"]
    let types = ["標準":MapStyle.standard,
                 "衛星照片":MapStyle.imagery,
                 "混合":MapStyle.hybrid]
    
    var body: some View {
        let l1 = CLLocationCoordinate2D(
            latitude: 25.04729,
            longitude: 121.51356)
        let l2 = CLLocationCoordinate2D(
            latitude: 25.04729,
            longitude: 121.5216)
        var initialRegion = [
            MKMapItem(placemark: MKPlacemark(coordinate: l1)),
            MKMapItem(placemark: MKPlacemark(coordinate: l2))]
        
        VStack {
            Picker("", selection: $mapType){
                ForEach(typesName,id:\.self){ type in
                   Text(type)
                }
            }
            .pickerStyle(.segmented)

            HStack{
                TextField("輸入搜尋關鍵字", text: $searchKeyWord)
                    .border(.gray)
                    .padding()
                Button {
                    searchMapItem(searchKeyWord, self.region)
                    print("search.region:\n\(self.region.center)\(self.region.span)")
                } label: {
                    Image(systemName: "magnifyingglass")
                }

            }
//            Map(position: .constant(.region(region))){
            Map(position: $camPosition){
//                Marker("L1", coordinate: l1)
//                Marker("L2", coordinate: l2)
                ForEach(initialRegion,id:\.self){item in
                    Annotation("", coordinate: item.placemark.coordinate) {
                    }
                }
             
                UserAnnotation {
                    Image(systemName: "car")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 40,height: 40)
                        
                }
//                Annotation("我設的台北車站",
//                           coordinate: location) {
//                    Button{
//                        print("hello world")
//                    }label:{
//                        Image(systemName: "tram.circle.fill")
//                            .foregroundColor(.red)
//                    }
//                }
                
                ForEach(searchResult,id:\.self){item in
                    Marker(item: item)
                }
                
            }
            .mapStyle(types[mapType]!)
            .clipped()
            .scaleEffect(scale)
            .onAppear(){
                withAnimation(.easeInOut(duration: 1)) {
                    scale = 1
                }


                
            }
            .onAppear()
            {
                initialRegion.removeAll()
                locationManager.requestWhenInUseAuthorization()
                locationManager.delegate = locationManagerDelegate
                //                if CLLocationManager.locationServicesEnabled() {
                //                    locationManager.startUpdatingLocation()
                //                }
                //                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                //                    if let center = locationManagerDelegate.location?.coordinate {
                //                        camPosition = .region(MKCoordinateRegion(
                //                            center: center,
                //                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                //                    }
                //                }
                
            }
//            .onChange(of: searchResult) {
//                camPosition = .automatic
//            }
            .onMapCameraChange { context in
                self.region = context.region
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }   
        }
    }
    
    func searchMapItem(_ query:String,_ region:MKCoordinateRegion){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = region
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResult = response?.mapItems ?? []
        }
    }
}

#Preview {
    ContentView()
}
