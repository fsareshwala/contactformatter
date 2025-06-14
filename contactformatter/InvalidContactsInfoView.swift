import SwiftUI

struct InvalidContactsInfoView: View {
  @Binding var isPresented: Bool

  var body: some View {
    VStack {
      Spacer()

      WarningHeaderView()

      VStack {
        Text(
          """
          Invalid contacts are those which have phone numbers that Clean Dial cannot parse and \
          will not format. Please update your contacts with valid phone numbers and try again.
          """
        )
        .padding()
      }
      .font(.callout)
      .multilineTextAlignment(.center)

      Spacer()

      Button(action: { isPresented = false }) {
        Text("Dismiss")
          .font(.headline)
      }
      .buttonStyle(.borderless)
      .padding()
    }
  }
}

#Preview {
  InvalidContactsInfoView(isPresented: .constant(true))
}
