
import SwiftUI

struct DayDateCardView: View {
    
    var viewModel: FeedViewModel
    
    var body: some View {
        
        HStack(spacing: 56) {
            DateDayView(dateText: viewModel.startDate,
                        dayHourText: viewModel.eventHourFirstDay)
            DateDayView(dateText: viewModel.endDate,
                        dayHourText: viewModel.eventHourSecondDay)
        }
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(Color.white)
        .cornerRadius(4)
        .padding(.horizontal, 10)
        .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 6)
    }
}

struct ConfInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DayDateCardView(viewModel: FeedViewModel())
    }
}

struct DateDayView: View {
    var dateText = "09 NOV"
    var dayHourText = "Sábado - 09:00h"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateText)
                .foregroundColor(.primary)
                .font(.title)
                .fontWeight(.semibold)
            
            Text(dayHourText)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
}
