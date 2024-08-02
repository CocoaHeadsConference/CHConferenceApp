import SwiftUI

#if !os(watchOS)
public struct HomeTabBar: View {
    public init(model: FeedViewModel) {
        UITabBar.appearance().backgroundColor = UIColor(hexString: "#1D3115")
        viewModel = model
    }

    enum SelectedMenu: Int {
        case home
        case schedule
    }

    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State var currentlySelectedMenu: Int? = 0
    
    public var body: some View {
        ZStack {
            switch viewModel.isLoading {
            case .loading:
                ProgressView()
            case .loaded:
                loadedBody
            case .failed:
                errorBody
            }
        }
    }

    @ViewBuilder
    var loadedBody: some View {
        if horizontalSizeClass == .regular {
            largeScreenView
        } else {
            smallScreenView
        }
    }

    var largeScreenView: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: homeListView,
                    tag: 0,
                    selection: $currentlySelectedMenu,
                    label: {
                        Label("Home", systemImage: "house.fill")
                    })

                NavigationLink(
                    destination: scheduleListView,
                    tag: 1,
                    selection: $currentlySelectedMenu,
                    label: {
                        Label("Agenda", systemImage: "calendar")
                    })
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("NSBrazil")
        }
    }

    var smallScreenView: some View {
        TabView {
            homeListView
            scheduleListView
        }
        .navigationBarTitle("NSBrazil")
        .accentColor(Color(UIColor.label))
    }

    var homeListView: some View {
        HomeList(feedViewModel: self.viewModel).tabItem ({
            VStack {
                Image(systemName: "house.fill")
                    .imageScale(.large)
                    .accentColor(Color(UIColor.label))
                Text("Home")
            }
        })
        .tag(1)
    }

    var scheduleListView: some View {
        ScheduleListView(viewModel: self.viewModel).tabItem({
            VStack {
                Image(systemName: "calendar")
                    .imageScale(.large).accentColor(Color(UIColor.label))
                Text("Schedule")
            }
        })
        .tag(2)
    }

    var errorBody: some View {
        VStack(spacing: 20) {
            Text("Algo deu errado")
                .font(Font.title.bold())

            Button(action: {
                self.viewModel.fetchInfo()
            }, label: {
                Text("Tentar novamente")
            })
        }
    }
}

#Preview {
  HomeTabBar(model: .mock)
}
#endif
