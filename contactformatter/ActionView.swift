import SwiftUI

struct ActionView: View {
  let message: String
  let button: String
  let action: () -> Void

  var body: some View {
    VStack {
      Spacer()
      MessageView(message: message)
      Spacer()

      Button(action: {
        action()
      }) {
        Text(button)
          .font(.headline)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding(.bottom)
    }
  }
}

#Preview {
  ActionView(message: "message", button: "button", action: {})
}
