
import SwiftUI

struct HomeTabBar: View {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(hexString: "#1D3115")
    }
    
    var body: some View {
        TabView {
            HomeList(feedViewModel: FeedViewModel()).tabItem ({
                VStack {
                    Image("IconHome")
                    Text("Home")
                }
            })
            .tag(1)
            
            ScheduleListView(scheduleViewModel: ScheduleListViewModel()).tabItem({
                VStack {
                    Image("IconCards")
                    Text("Schedule")
                }
            })
            .tag(2)
        }
        .navigationBarTitle("NSBrazil")
        .edgesIgnoringSafeArea(.top)
        .accentColor(Color(UIColor.label))
        
    }
}

struct HomeTabBar_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabBar()
    }
}
