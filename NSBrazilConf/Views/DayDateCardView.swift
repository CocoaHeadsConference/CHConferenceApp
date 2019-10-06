
import SwiftUI

struct DayDateCardView: View {
    
    @ObservedObject var feed = NSBrazilStore()
    
    var body: some View {
        
        HStack(spacing: 56) {
            DateDayView(dateText: feed.confMock.feed[0].startDateText,
                        dayHourText: feed.confMock.feed[0].startEventHourText)
            DateDayView(dateText: feed.confMock.feed[0].endDateText,
                        dayHourText: feed.confMock.feed[0].endEventHourText)
        }
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(Color.white)
        .cornerRadius(4)
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .shadow(radius: 10)
    }
}

struct ConfInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DayDateCardView()
    }
}

struct DateDayView: View {
    var dateText = "09 NOV"
    var dayHourText = "Sábado - 09:00h"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateText)
                .font(.title)
                .fontWeight(.semibold)
            
            Text(dayHourText)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
}
