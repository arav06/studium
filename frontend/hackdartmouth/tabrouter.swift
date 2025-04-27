import SwiftUI

class TabRouter: ObservableObject {
    @Published var currentTab: Tab = .home
}

enum Tab {
    case home
    case invites
    case matches
    case profile
}
