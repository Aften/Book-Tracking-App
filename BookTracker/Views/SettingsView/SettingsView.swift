//  SettingsView.swift
//  ClassProject
//
//  Created by Aften.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var homeModel = NavigationModel()
    @State private var currentAlert: AlertType?
    @StateObject var bookViewModelObj = BookViewModel()

    // Enum to handle alerts
    enum AlertType: Int, Identifiable {
        case logout, postLogout
        
        var id: Int {
            self.rawValue
        }
    }
    
    var body: some View {
        ZStack {
            Image("Settings")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    currentAlert = .logout
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .cornerRadius(10)
                        .opacity(0)
                }
                .padding(.horizontal, UIScreen.main.bounds.width * 0.06)
                .padding(.top, 73)
                
                // Alert views to handle logout functionality. Deletes all data from database and returns to main view.
                .alert(item: $currentAlert) { alertType in
                    switch alertType {
                    case .logout:
                        return Alert(title: Text("Log Out"), message: Text("Warning: if you log out all of the stored books will be permanently deleted!"), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Log Out"), action: {
                            bookViewModelObj.deleteAll()
                            currentAlert = .postLogout
                        }))
                    case .postLogout:
                        return Alert(title: Text(""), message: Text("Successfully logged out, you will now be taken to the home screen."),dismissButton: .default(Text("OK"), action:{
                            homeModel.showHomeView.toggle()
                        }))
                    }
                }
                
                Spacer()
                
                // Hstack to handle navigation, uses buttons.
                HStack(spacing: 10) {
                    Button(action: {
                        homeModel.showHomeView.toggle()
                    }) {
                        Text("Button 1")
                            .padding()
                            .opacity(0)
                    }
                                        
                    Button(action: {
                        homeModel.showMapView.toggle()
                    }) {
                        Text("Button 2")
                            .opacity(0)
                    }
                    
                    Button(action: {
                        homeModel.showSettingsView.toggle()
                    }) {
                        Text("Button 3")
                            .opacity(0)
                    }
                }
                .padding(.bottom, 30)
            }
            
            ForEach(homeModel.views) { viewState in
                if viewState.isVisible {
                    viewState.view
                }
            }
        }
    }
}

