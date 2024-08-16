import SwiftUI

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

struct ConfInfoView_Previews: PreviewProvider {
  static var previews: some View {
    DateDayView()
  }
}
