//
//  TabRouter.swift
//  Sports
//
//  Created by joao gabriel medeiros pereira on 05/10/24.
//
import SwiftUI

enum TabRoute: Routable {
    case home
    case commingSoon
    
    var body: some View {
        switch self {
        case .home:
            HomeView()
        case .commingSoon:
            CommingSoonView()
        }
    }
}

@Observable
public final class TabRouter<Routes: Routable>: TabRoutableObject {
    public typealias Destination = Routes

    public var selectedTab: Routes

    public init(selectedTab: Routes) {
        self.selectedTab = selectedTab
    }
}


public protocol TabRoutableObject: AnyObject {
    /// The type of the destination views in the navigation stack. Must conform to `Routable`.
    associatedtype Destination: Routable

    /// An array representing the current navigation stack of destinations.
    /// Modifying this stack updates the navigation state of the application.
    var selectedTab: Destination { get set }
}
