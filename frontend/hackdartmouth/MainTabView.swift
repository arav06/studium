import SwiftUI

struct MainTabView: View {
    @StateObject var tabRouter = TabRouter()

    var body: some View {
        TabView(selection: $tabRouter.currentTab) {
            HomePage()
                .tabItem {
                    Label("Find", systemImage: "magnifyingglass")
                }
                .tag(Tab.home)

            InvitationsPage()
                .tabItem {
                    Label("Invites", systemImage: "envelope")
                }
                .tag(Tab.invites)

            MatchesPage()
                .tabItem {
                    Label("Matches", systemImage: "person.2.fill")
                }
                .tag(Tab.matches)
            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
        .environmentObject(tabRouter)
    }
}
