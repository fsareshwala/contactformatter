import SwiftUI

struct MessageView: View {
  let message: String

  var body: some View {
    VStack {
      LogoHeaderView()
      Text(message)
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}

#Preview {
  MessageView(message: "foo")
}
