import SwiftUI

struct LogoView: View {
  var body: some View {
    VStack {
      Image(systemName: "person.crop.circle.badge.checkmark")
        .symbolRenderingMode(.multicolor)
        .resizable()
        .scaledToFit()
        .frame(width: 85, height: 85)

      Text("Clean Dial")
        .font(.largeTitle)
        .bold()
        .padding(.bottom, 10)
    }
  }
}
