//
//  ScheduleListView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI

import SwiftUI

struct ScheduleListView: View {
    var updates = updateData
    @ObservedObject var store = UpdateStore()
    
    @State var showSetting = false
    

    func move(from source: IndexSet, to destination: Int) {
        store.updates.swapAt(source.first!, destination)
    }

    var body: some View {
        NavigationView {
            List{
                ForEach(store.updates) { item in
                    NavigationLink(destination:
                    TalkDetail(
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
                .onMove(perform: move)
                
            }
            .navigationBarTitle(Text("Schedule"))
        }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView()
    }
}

struct Update: Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var text: String
    var date: String
}

