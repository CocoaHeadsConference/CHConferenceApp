
import SwiftUI

struct HomeTabBar: View {

    init() {
        UITabBar.appearance().backgroundColor = UIColor(hexString: "#1D3115")
    }

    @ObservedObject var viewModel = FeedViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ActivityIndicatorView()
            } else {
                TabView {
                    HomeList(feedViewModel: self.viewModel).tabItem ({
                        VStack {
                            Image(systemName: "house.fill")
                                .imageScale(.large)
                                .accentColor(Color(UIColor.label))
                            Text("Home")
                        }
                    })
                    .tag(1)

                    ScheduleListView(viewModel: self.viewModel).tabItem({
                        VStack {
                            Image(systemName: "calendar")
                                .imageScale(.large).accentColor(Color(UIColor.label))
                            Text("Schedule")
                        }
                    })
                    .tag(2)
                }
                .navigationBarTitle("NSBrazil")
                .accentColor(Color(UIColor.label))
            }
        }
    }
}

struct HomeTabBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeTabBar()
            HomeTabBar().environment(\.colorScheme, .dark)
        }
    }
}
