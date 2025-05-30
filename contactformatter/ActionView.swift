import SwiftUI

struct ActionView: View {
  let message: String
  let button: String
  let action: () -> Void

  var body: some View {
    VStack {
      Spacer()

      Image(systemName: "person.2.badge.plus")
        .resizable()
        .renderingMode(.original)
        .scaledToFit()
        .frame(width: 100, height: 100)

      Text("Clean Dial")
        .font(.title)
        .bold()

      Text(message)
        .font(.callout)
        .padding()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)

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
