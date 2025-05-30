import SwiftUI

struct MessageView: View {
  let message: String

  var body: some View {
    VStack {
      Image(systemName: "book.and.wrench.fill")
        .resizable()
        .renderingMode(.original)
        .scaledToFit()
        .frame(width: 100, height: 100)

      Text("Clean Dial")
        .font(.title)
        .bold()

      Text(message)
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}
