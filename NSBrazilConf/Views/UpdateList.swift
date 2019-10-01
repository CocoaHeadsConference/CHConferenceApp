
import SwiftUI

struct ScheduleListView: View {
    var updates = updateData
    @ObservedObject var store = UpdateStore()
    
    @State var showSetting = false
    
    func addUpdate() {
        store.updates.append(Update(image: "Certificate1", title: "New Title", text: "New Text", date: "JUL 1"))
    }
    
    func move(from source: IndexSet, to destination: Int) {
        store.updates.swapAt(source.first!, destination)
    }

    var body: some View {
        NavigationView {
            List{
                ForEach(store.updates) { item in
                    NavigationLink(destination:
                    UpdateDetail(
                        title: item.title,
                        text: item.text,
                        image: item.image)) {
                            HStack(spacing: 12.0) {
                                Image(item.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .background(Color("background"))
                                .cornerRadius(40)
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                        
                                    Text(item.text)
                                        .lineLimit(3)
                                        .font(.system(size: 15))
                                        .lineSpacing(4)
                                        .frame(height: 50)
                                    
                                    Text(item.date)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    .padding(.vertical, 8.0)
                    
                }
                .onDelete { index in
                    guard let idx = index.first else { return }
                    self.store.updates.remove(at: idx)
                }
                .onMove(perform: move)
                
            }
            .navigationBarTitle(Text("Palestras"))
        }
    }
}

struct UpdateList_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView()
    }
}

struct Update: Codable, Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var text: String
    var date: String
}


