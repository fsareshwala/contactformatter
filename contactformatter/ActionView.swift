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
          .foregroundColor(.white)
          .frame(minWidth: 200)
          .padding()
          .background(Color.accentColor)
          .cornerRadius(10)
      }
      .padding(.bottom, 50)
    }
  }
}
