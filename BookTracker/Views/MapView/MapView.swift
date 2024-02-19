//
//  MapView.swift
//  ClassProject
//
//  Created by Aften.
//

import SwiftUI
import _MapKit_SwiftUI

struct MapView: View {
    
    @ObservedObject var homeModel = NavigationModel()
    @ObservedObject var mapModel = MapModel()
    
    // Creates render for map to display to user
    var body: some View {
        ZStack {
            Image("Map")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack {
                    MapViewRepresentable(mapModel: mapModel)
                        .frame(height: geometry.size.height * 0.5)
                        .edgesIgnoringSafeArea(.all)
                        .offset(y:120)
                        .onChange(of: mapModel.region, perform: { region in
                            withAnimation {
                                mapModel.region = region
                            }
                        })
                        .onAppear {
                            mapModel.requestLocationPermission()
                            mapModel.centerOnUserLocation()
                            mapModel.findNearbyBookstores()
                        }
                    // List of book stores near user in a scroll view
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(mapModel.stores) { store in
                                Button(action: {
                                    mapModel.zoomToStore(store)
                                }) {
                                    Text(store.name)
                                        .font(.headline)
                                        .padding(.leading, 16)
                                        .padding(.bottom, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.top, 16)
                    }
                    .offset(y:113)
                    .frame(height: geometry.size.height * 0.6 - 290)
                }
                
                // navigation buttons
                VStack {
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            homeModel.showHomeView.toggle()
                        }) {
                            Text("Button 1")
                                .opacity(0)
                                .padding(.leading, 90)
                        }
                        Button(action: {
                            homeModel.showMapView.toggle()
                        }) {
                            Text("Button 2")
                                .padding()
                                .opacity(0)
                        }
                        
                        Button(action: {
                            homeModel.showSettingsView.toggle()
                        }) {
                            Text("Button 3")
                                .padding()
                                .opacity(0)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            
            ForEach(homeModel.views) { viewState in
                if viewState.isVisible {
                    viewState.view
                }
            }
        }
    }
}

