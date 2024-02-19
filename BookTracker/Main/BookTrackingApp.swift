//
//  BookTrackingApp.swift
//  Book Tracking App
//
//  Created by Aften.
//

import SwiftUI
import Firebase

// App delegate inits
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct ClassProjectApp: App {
    // Registers app for firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // State object for data models
    @StateObject var bookViewModelObj = BookViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environmentObject(bookViewModelObj)
            }
        }
    }
}
