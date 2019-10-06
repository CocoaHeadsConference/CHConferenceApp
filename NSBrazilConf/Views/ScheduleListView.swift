//
//  ScheduleListView.swift
//  NSBrazilConf
//
//  Created by resource on 01/10/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import SwiftUI


struct ScheduleListView: View {

    let scheduleViewModel: ScheduleListViewModel
    
    @State var showSetting = false
    
    var body: some View {
        NavigationView {
            List{
                ForEach(scheduleViewModel.talksFirstDay) { talk in
                    NavigationLink(destination:
                    TalkDetail(talk: talk)) {
                            HStack(spacing: 12.0) {
                                Image(talk.speakerImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .background(Color("background"))
                                .cornerRadius(40)
                                
                                VStack(alignment: .leading) {
                                    Text(talk.title)
                                        .font(.headline)
                                        
                                    Text(talk.speaker)
                                        .lineLimit(3)
                                        .font(.system(size: 14))
                                        .lineSpacing(4)
                                        .frame(height: 50)
                                    
                                    Text("\(talk.date)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    .padding(.vertical, 8.0)
                    
                }
                
            }
            .navigationBarTitle(Text("Schedule"))
        }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView(scheduleViewModel: ScheduleListViewModel())
    }
}
