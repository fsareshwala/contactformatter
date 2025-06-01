import SwiftUI

struct LogoView: View {
  var body: some View {
    VStack {
      Image(systemName: "book.and.wrench.fill")
        .resizable()
        .foregroundStyle(.tint)
        .scaledToFit()
        .frame(width: 85, height: 85)

      Text("Clean Dial")
        .font(.largeTitle)
        .bold()
        .padding(.bottom, 50)
    }
  }
}
