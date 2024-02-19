//
//  HomeScreenModel.swift
//  ClassProject
//
//  Created by Aften.
//

import Foundation
import SwiftUI

// Class to handle view changes
final class NavigationModel: ObservableObject {
    @Published var showHomeView = false
    @Published var showMapView = false
    @Published var showSettingsView = false
    @Published var showUnReadView = false
    
    struct ViewState: Identifiable {
        var id: UUID
        var isVisible: Bool
        var view: AnyView
    }

    var views: [ViewState] {
        [
            ViewState(id: UUID(), isVisible: showHomeView, view: AnyView(HomeView())),
            ViewState(id: UUID(), isVisible: showMapView, view: AnyView(MapView())),
            ViewState(id: UUID(), isVisible: showSettingsView, view: AnyView(SettingsView())),
        ]
    }
    
    func navigateToView(_ view: String) {
        showHomeView = view == "home"
        showMapView = view == "map"
        showSettingsView = view == "settings"
        showUnReadView = view == "unread"
    }

    
}

extension LibraryBook {
    var isActive: Binding<Bool> {
        .init(
            get: { self.id != nil },
            set: { _ in }
        )
    }
}
